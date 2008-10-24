module Cucumber
  module Mate

    module Files
    
      class FeatureFile < Base
        class << self
          def default_content(file_path, additional_content = nil)
            TextMateHelper.snippet_text_for('Feature')
          end
        end
        
        def feature_file?; true; end
        
        def alternate_file_path
          steps_file_path
        end
        
        def rake_task
          content_lines.detect {|line| line =~ /^\s*#\s*rake\s+([\w:]+)/} ? $1 : nil
        end
        
        def profile
          content_lines.detect {|line| line =~ /^\s*#\s*profile\s+([\w]+)/} ? $1 : nil
        end
        
        
        def step_files_and_names
          StepDetector.new(full_file_path).step_files_and_names
        end
        
        alias :alternate_files_and_names :step_files_and_names
        
        def step_information_for_line(line_number)
          line_index = line_number.to_i-1
                    
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
          step_files_and_names.detect{|step_file_info| step_file_info[:name] == "#{step_file_name} steps"} ? true : false
        end      
        
        def undefined_steps
          undefined_steps = []
          all_steps_in_file.each do |step_info|
            unless location_of_step(step_info) || undefined_steps.any?{|s| s[:step_type] == step_info[:step_type] && s[:step_name] == step_info[:step_name]}
              undefined_steps << step_info
            end
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
        
        def content_lines
          @content_lines ||= File.read(full_file_path).split("\n")
        end
        
        def all_defined_steps
          @defined_steps ||= gather_defined_steps
        end                  
        
        def gather_defined_steps
          step_definitions = []
          step_files_and_names.each do |step_file_info|
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
