require 'rubygems'
require 'spec/story/step'

module Cucumber
  module Mate

    module Files
    
      class StepsFile < Base
        class << self
          def default_content(file_path, additional_content = create_steps([:step_type => 'Given', :step_name => 'condition']))
            additional_content || ""
          end
          
          def create_steps(steps_to_create, already_included_snippet_selection = true)
            sorted_steps = steps_to_create.inject({'Given' => [], 'When' => [], 'Then' => []}) do |steps_so_far, current_step_info|
              steps_so_far[current_step_info[:step_type]] << current_step_info[:step_name]
              steps_so_far
            end
            
            content = ""
            %w(Given When Then).each do |step_type|
              sorted_steps[step_type].each do |step_name|
                step_name_text = already_included_snippet_selection ? step_name : "${1:#{step_name}}"
                content += %Q{  #{step_type} "#{step_name_text}" do\n    pending\n  end\n  \n}
                already_included_snippet_selection = true
              end
            end
            content
          end
        end
        
        def steps_file?; true; end
        
        def new_steps_line_number
          if File.file?(full_file_path)
            contents = File.read(full_file_path)
            
            contents.split("\n").each_with_index do |line, index|
              return index + 2 if line =~ /\s*steps_for/
            end
            
            return 2
          end
        end
        
        def name
          @name ||= super.gsub("_steps", "")
        end
        
        def rake_task
          feature_file.rake_task
        end
        
        def profile
          feature_file.profile
        end
        
        def alternate_file_path
          feature_file_path
        end  
    
        def feature_files_and_names
          feature_files = []
          feature_files = FeatureFile.all.select {|feature| feature.includes_step_file?(name) }
          feature_files.map {|feature_file| {:name => "#{feature_file.name} feature", :file_path => feature_file.full_file_path} }
        end
        
        alias :alternate_files_and_names :feature_files_and_names
        
        def step_definitions
          if File.file?(full_file_path)
            @steps = []
            @file_contents = File.read(full_file_path)
            eval(@file_contents)
            @steps
          else
            []
          end
        end
        
      protected
        # While evaluating step definitions code - This called when a new step has been parse
        # We need to save these to be able to match plain text 
        def add_step(type, pattern)
          step = Spec::Story::Step.new(pattern){raise "Step doesn't exist."}
          
          line_number = caller[1].match(/:(\d+)/).captures.first.to_i
          
          next_line = @file_contents.split("\n")[line_number]
          
          col_number =  if (md = next_line.match(/\s*[^\s]/))
                          md[0].length
                        elsif (md = next_line.match(/\s*$/))
                          md[0].length + 1
                        else
                          1
                        end
          
          @steps << {:step => step, :type => type, :pattern => pattern, :line => line_number + 1,
                      :column => col_number, :file_path => full_file_path, :group_tag => name}
        end
        
        def steps_for(*args)
          yield if block_given?
        end
        
        def feature_file
          @feature_file ||= FeatureFile.new(feature_file_path)
        end

        def Given(pattern)
          add_step('Given', pattern)
        end

        def When(pattern)
          add_step('When', pattern)
        end

        def Then(pattern)
          add_step('Then', pattern)
        end
      end
      
    end

  end
end
