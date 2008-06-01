require File.dirname(__FILE__)+'/../text_mate_helper'
require 'rubygems'
require 'spec/story/step'

module Spec
  module Mate
    module Story
      
      class StoryHelper
        def initialize(project_root, full_file_path)
          @project_root = project_root
          @full_file_path = full_file_path
          
          @steps = []
          @step_file_contents = {}
        end
        
        def goto_alternate_file
          alt_file_path = alternate_file(full_file_path)
          if ::Spec::Mate::TextMateHelper.open_or_prompt(alt_file_path) == true
            ::Spec::Mate::TextMateHelper.insert_text(default_content(alt_file_path))
          end
        end
        
        def goto_current_step(current_line_number)
          return unless is_story_file?
          
          current_step_type, current_step_name = get_current_step_info(current_line_number)
          if current_step_type
            goto_new_or_current_step(current_step_type, current_step_name)
          end
        end
        
        def choose_steps_file
          if step_names = related_step_files
            step_file_index = TextMate::UI.menu(step_names)
            exit if step_file_index.nil?
            ::Spec::Mate::TextMateHelper.open_or_prompt(full_path_for_step_name(step_names[step_file_index]))
          end
        end
        
        def create_uninplemented_steps
          return unless is_story_file?
          step_types_and_names_to_create = unlimplmemated_steps_for(full_file_path)
          open_or_create_steps_file(alternate_file(full_file_path), step_types_and_names_to_create)
        end
        
      protected
        attr_reader :full_file_path, :project_root
        
        def open_or_create_steps_file(file_path, step_types_and_names_to_create = [["Given", "condition"]])
          create_return_value = ::Spec::Mate::TextMateHelper.open_or_prompt(file_path, :line_number => 2, :column_number => 1)
          if create_return_value == true # File was created
            ::Spec::Mate::TextMateHelper.insert_text(steps_content(file_path, step_types_and_names_to_create))
          elsif create_return_value != false # File already existed
            #text = ::Spec::Mate::TextMateHelper.snippet_text_for("#{proper_case_step_type} Step", current_step_name)
            ::Spec::Mate::TextMateHelper.insert_text(steps_content(nil, step_types_and_names_to_create))
          end
        end
        
        # Story file should be passed in
        # TODO: add more funcionality around this
        def create_runner_file_for(file_path)
          return if File.file?(story_runner_file_for(file_path))
          ::Spec::Mate::TextMateHelper.silently_create_file_with_contents(story_runner_file_for(file_path), default_content(story_runner_file_for(file_path)))
        end
             
        def unlimplmemated_steps_for(file_path)
          return unless is_story_file?(file_path)
          
          runner_file_path = story_runner_file_for(file_path)
          create_runner_file_for(file_path) unless File.file?(runner_file_path)
          
          # Get all currently defined steps (from relevent files)
          step_hashes = all_steps_for_file(file_path)
          
          # Get all plain text steps from story file
          story_text_steps = all_text_steps_in_story(file_path)
          
          uninplemented_text_steps = []
          story_text_steps.each do |plain_text_type, plain_text_step|
            unless step_hashes.detect{|s| s[:type].downcase == plain_text_type.downcase && s[:step].matches?(plain_text_step) }
              uninplemented_text_steps << [plain_text_type, plain_text_step]
            end
          end
          
          uninplemented_text_steps.uniq
        end
        
        def all_text_steps_in_story(file_path)
          file_lines = File.read(file_path).split("\n").collect{|l| l.strip}
          
          text_steps = []
          step_type = 'unknown'
          file_lines.each do |line|
            step_type = $1 if line.match(/^(Given|When|Then)\s+/)
            text_steps << [step_type, $2] if line.match(/^(Given|When|Then|And)\s+(.*)$/)
          end
          
          text_steps
        end
        
        # HAS TO TAKE STORY FILE - will find all steps that the runner file includes
        def all_steps_for_file(file_path)
          runner_file_path = story_runner_file_for(file_path)
          
          create_runner_file_for(file_path) unless File.file?(runner_file_path)
          
          step_group_tags = parse_step_group_tags(File.read(runner_file_path))
          
          step_group_tags.each do |step_group_tag|
            @current_step_group_tag = step_group_tag
            @full_steps_file_path = full_path_for_step_name(@current_step_group_tag)
            next unless @full_steps_file_path
            
            @step_file_contents[@current_step_group_tag] = File.read(@full_steps_file_path)
            eval(@step_file_contents[@current_step_group_tag])
          end
          
          @steps
        end
        
        def find_matching_step(current_step_type, current_step_name)
          all_steps_for_file(full_file_path)
          
          # Find matching step
          @steps.detect{|s| s[:type] == current_step_type && s[:step].matches?(current_step_name) }
        end
        
        # While evaluating step definitions code - This called when a new step has been parse
        # We need to save these to be able to match plain text 
        def add_step(type, pattern)
          step = Spec::Story::Step.new(pattern){raise "Step doesn't exist."}
          @steps << {:file => @full_steps_file_path, :step => step, :type => type, 
                      :pattern => pattern, :tag => @current_step_group_tag,
                      :line_number => caller[1].match(/:(\d+)/).captures.first.to_i}
        end
        
        def goto_new_or_current_step(current_step_type, current_step_name)
          if (matching_step = find_matching_step(current_step_type, current_step_name))
            next_line = @step_file_contents[matching_step[:tag]].split("\n")[matching_step[:line_number]]
            col_number = (md = next_line.match(/\s*($|[^\s])/)) ? md[0].length : 1
            ::Spec::Mate::TextMateHelper.open_or_prompt(matching_step[:file], :line_number => matching_step[:line_number]+1, :column_number => col_number)
          else
            open_or_create_steps_file(alternate_file(full_file_path),
              [["#{current_step_type[0...1].upcase}#{current_step_type[1..-1].downcase}", current_step_name]])
          end
        end
        
        def get_current_step_info(line_number)
          line_index = line_number.to_i-1
          content_lines = File.read(full_file_path).split("\n")
          
          line_text = content_lines[line_index].strip
          return unless line_text.match(/^(given|when|then|and)(.*)/i)
          source_step_name = $2.strip
          
          step_type_line = content_lines[0..line_index].reverse.detect{|l| l.match(/^\s*(given|when|then)\s*(.*)$/i)}
          step_type = $1.downcase
          
          return step_type, source_step_name
        end
        
        def default_content(file_path)
          case file_path
          when /(story|txt)$/ then story_content(file_path)
          when /_steps\.rb$/  then steps_content(file_path)
          when /stories\/([^\/\.]*).rb/ then runner_content(file_path)
          else ''
          end
        end
        
        def runner_content(file_path)
          story_name = file_path.match(/([^\/]*).rb$/).captures.first
          num_paths_up = file_path.match(/^.*?\/stories\/(.*)$/).captures.first.split('/').size - 1
          content = <<-EOF
require File.join(File.dirname(__FILE__), #{("'..', " * num_paths_up) + "'helper'"})

with_steps_for :#{story_name} do
  run_story(File.expand_path(__FILE__))
end
EOF
        end
        
        def story_content(file_path)
          ::Spec::Mate::TextMateHelper.snippet_text_for('Story')
        end
        
        def steps_content(file_path, step_types_and_names_to_create = [["Given", "condition"]])
          create_wrapper_content = false
          
          if file_path
            create_wrapper_content = true
            step_file_name = file_path.match(/([^\/]*)_steps.rb$/).captures.first
          end
          
          # sort the steps into Given, When, Then
          sorted_steps = step_types_and_names_to_create.inject({'Given' => [], 'When' => [], 'Then' => []}) do |steps_so_far, current_type_and_step_name|
            steps_so_far[current_type_and_step_name.first] << current_type_and_step_name.last
            steps_so_far
          end
          
          content = ""
          content = %Q{steps_for(:${1:#{step_file_name}}) do\n} if create_wrapper_content
          
          already_included_snippet_selection = false
          %w(Given When Then).each do |step_type|
            sorted_steps[step_type].each do |step_name|
              step_name_text = already_included_snippet_selection ? step_name : "${1:#{step_name}}"
              content += %Q{  #{step_type} "#{step_name_text}" do\n    pending\n  end\n  \n}
              already_included_snippet_selection = true
            end
          end
          content += "end\n" if create_wrapper_content
          content
        end
        
        
        def alternate_file(path)
          if path =~ /^(.*)\/(steps|stories)\/(.*?)$/
            prefix, parent, rest = $1, $2, $3
            
            case parent
            when 'steps' then
              path = path.gsub(/\/steps\//, '/stories/')
              path = path.gsub(/_steps\.rb$/, '.story')
            when 'stories' then
              path = path.gsub(/\/stories\/([^\/]*)\.(story|txt)$/, '/steps/\1_steps.rb')
            end
            return path
          end
        end
        
        def related_step_files
          if is_story_file?(full_file_path)
            story_name = full_file_path.match(/\/([^\.\/]*)\.(story|txt)$/).captures.first
            steps_file_path = File.dirname(full_file_path) + "/../#{story_name}.rb"
            
            parse_step_group_tags(File.read(steps_file_path))
          else
            step_files = Dir["#{project_root}/stories/**/*_steps.rb"]
            step_files.collect{|f| f.match(/([^\/]*)_steps.rb$/).captures.first }.sort
          end
        end
        
        def story_runner_file_for(path)
          if is_story_file?(path)
            path.gsub(/\/stories\/([^\.\/]*)\.story$/, '/\1.rb')
          else # steps path
            path.gsub(/\/steps\/([^\.\/]*)_steps\.rb$/, '/\1.rb')
          end
        end
        
        def parse_step_group_tags(content)
          content.gsub!(/.*with_steps/m, 'with_steps')
          eval(content).collect{|step_tag| step_tag.to_s}
        end
        
        def full_path_for_step_name(step_name)
          possible_files = Dir["#{project_root}/**/stories/**/#{step_name}_steps.rb"]
          return if possible_files.empty?
          File.expand_path(possible_files.first)
        end
        
        def is_story_file?(file_path = full_file_path)
          file_path.match(/\.(story|txt)$/)
        end
        
        def with_steps_for(*args)
          return args
        end
        
        def steps_for(*args)
          yield if block_given?
        end
        
        def Given(pattern)
          add_step('given', pattern)
        end
        
        def When(pattern)
          add_step('when', pattern)
        end
        
        def Then(pattern)
          add_step('then', pattern)
        end
        
      end
      
    end
  end
end