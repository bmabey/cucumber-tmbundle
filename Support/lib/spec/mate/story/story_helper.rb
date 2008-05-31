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
        
      protected
        attr_reader :full_file_path, :project_root
        
        def default_content(file_path)
          case file_path
          when /(story|txt)$/ then story_content(file_path)
          when /_steps\.rb$/  then steps_content(file_path)
          else ''
          end
        end
        
        def story_content(file_path)
          ::Spec::Mate::TextMateHelper.snippet_text_for('Story')
        end

        def steps_content(file_path, step_type = 'Given', step_name = 'condition')
          step_file_name = file_path.match(/([^\/]*)_steps.rb$/).captures.first
          content = <<-STEPS
steps_for(:${1:#{step_file_name}}) do
  #{step_type} "${2:#{step_name}}" do
    $0
  end
end
STEPS
        end
        
        def goto_new_or_current_step(current_step_type, current_step_name)
          if (matching_step = find_matching_step(current_step_type, current_step_name))
            next_line = @step_file_contents[matching_step[:tag]].split("\n")[matching_step[:line_number]]
            col_number = (md = next_line.match(/\s*($|[^\s])/)) ? md[0].length : 1
            ::Spec::Mate::TextMateHelper.open_or_prompt(matching_step[:file], :line_number => matching_step[:line_number]+1, :column_number => col_number)
          else
            alt_file_path = alternate_file(full_file_path)
            proper_case_step_type = "#{current_step_type[0...1].upcase}#{current_step_type[1..-1].downcase}"
            
            create_return_value = ::Spec::Mate::TextMateHelper.open_or_prompt(alt_file_path, :line_number => 2, :column_number => 3)
            if create_return_value == true
              ::Spec::Mate::TextMateHelper.insert_text(steps_content(alt_file_path, proper_case_step_type, current_step_name))
            elsif create_return_value != false
              text = ::Spec::Mate::TextMateHelper.snippet_text_for("#{proper_case_step_type} Step", current_step_name)
              ::Spec::Mate::TextMateHelper.insert_text(text)
            end
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
        
        def find_matching_step(current_step_type, current_step_name)
          return unless File.file?(story_runner_file_for(full_file_path))
          step_group_tags = parse_step_group_tags(File.read(story_runner_file_for(full_file_path)))
          
          @steps = []
          @step_file_contents = {}
          
          step_group_tags.each do |step_group_tag|
            @current_step_group_tag = step_group_tag
            @full_steps_file_path = full_path_for_step_name(@current_step_group_tag)
            
            @step_file_contents[@current_step_group_tag] = File.read(@full_steps_file_path)
            eval(@step_file_contents[@current_step_group_tag])
          end
          
          # Find matching step
          @steps.detect{|s| s[:type] == current_step_type && s[:step].matches?(current_step_name) }
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
          return unless is_story_file?(path)
          path.gsub(/\/stories\/([^\.\/]*)\.story$/, '/\1.rb')
        end
        
        def parse_step_group_tags(content)
          content.gsub!(/.*with_steps/m, 'with_steps')
          eval(content).collect{|step_tag| step_tag.to_s}
        end
        
        def full_path_for_step_name(step_name)
          File.expand_path(Dir["#{project_root}/**/stories/**/#{step_name}_steps.rb"].first)
        end
        
        def is_story_file?(file_path = full_file_path)
          file_path.match(/\.(story|txt)$/)
        end
        
        
        def with_steps_for(*args)
          return args
        end
        
        def method_missing(method, args)
          yield if block_given?
        end
        
        def add_step(type, pattern)
          step = Spec::Story::Step.new(pattern){raise "Step doesn't exist."}
          @steps << {:file => @full_steps_file_path, :step => step, :type => type, 
                      :pattern => pattern, :tag => @current_step_group_tag,
                      :line_number => caller[1].match(/:(\d+)/).captures.first.to_i}
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