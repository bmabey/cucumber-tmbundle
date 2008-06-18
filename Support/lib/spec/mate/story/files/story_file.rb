module Spec
  module Mate
    module Story
      module Files
      
        class StoryFile < Base
          class << self
            def default_content(file_path, additional_content = nil)
              TextMateHelper.snippet_text_for('Story')
            end
          end
          
          def is_story_file?; true; end
          
          def name
            @name ||= full_file_path.match(/\/stories\/([^\.\/]*)\.(story|txt)$/).captures.first
          end
          
          def alternate_file_path
            steps_file_path
          end
          
          def runner_file_path
            @runner_file_path ||= full_file_path.gsub(%r</stories/#{name}\.(story|txt)$>, "/#{name}.rb")
          end
          
          def steps_file_path
            @steps_file_path ||= full_file_path.gsub(%r</stories/#{name}\.(story|txt)$>, "/steps/#{name}_steps.rb")
          end
          
          # Step files included in the runner file
          def alternate_files_and_names
            [{:name => "#{name.gsub('_', ' ')} runner", :file_path => runner_file_path}] + runner_step_files_and_names
          end
          
          def step_information_for_line(line_number)
            line_index = line_number.to_i-1
            content_lines = File.read(full_file_path).split("\n")
            
            line_text = content_lines[line_index]
            return unless line_text && line_text.strip!.match(/^(given|when|then|and)(.*)/i)
            source_step_name = $2.strip
            
            step_type_line = content_lines[0..line_index].reverse.detect{|l| l.match(/^\s*(given|when|then)\s*(.*)$/i)}
            source_step_type = $1
            
            return {:step_type => source_step_type, :step_name => source_step_name}
          end
          
          # Right now will return first matching step
          def location_of_step(step_info)
            all_defined_steps.each do |step_def|
              return step_def if step_def[:type] == step_info[:step_type] && step_def[:step].matches?(step_info[:step_name])
            end
            return nil
          end
          
          def includes_step_file?(step_file_name)
            step_file_name = step_file_name.gsub(' steps', '').gsub('_', ' ')
            runner_step_files_and_names.detect{|step_file_info| step_file_info[:name] == "#{step_file_name} steps"} ? true : false
          end
          
          def runner_step_files_and_names
            @runner_step_files_nad_names ||= RunnerFile.new(runner_file_path).step_files_and_names
          end
          
          def undefined_steps
            undefined_steps = []
            all_steps_in_file.each do |step_info|
              undefined_steps << step_info unless location_of_step(step_info)
            end
            undefined_steps
          end
        protected
          def all_steps_in_file
            file_lines = File.read(full_file_path).split("\n").collect{|l| l.strip}
            
            text_steps = []
            step_type = 'unknown'
            file_lines.each do |line|
              step_type = $1 if line.match(/^(Given|When|Then)\s+/)
              text_steps << {:step_type => step_type, :step_name => $2} if line.match(/^(Given|When|Then|And)\s+(.*)$/)
            end
            
            text_steps
          end
          
          def all_defined_steps
            @defined_steps ||= gather_defined_steps
          end
          
          def gather_defined_steps
            step_definitions = []
            RunnerFile.new(runner_file_path).step_files_and_names.each do |step_file_info|
              StepsFile.new(step_file_info[:file_path]).step_definitions.each do |step_def|
                step_definitions << step_def
              end
            end
            step_definitions
          end
        end
        
      end
    end
  end
end
