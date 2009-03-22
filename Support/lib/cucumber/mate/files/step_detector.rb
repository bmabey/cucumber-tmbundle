module Cucumber
  module Mate

    module Files

      class StepDetector
        def initialize(path_to_a_feature_file)
          @step_files = (
            Dir[File.dirname(path_to_a_feature_file) + "/step_definitions/**/*.rb"] +
            Dir[File.dirname(path_to_a_feature_file) + "/**/*_steps.rb"]
          ).uniq
        end

        # returns [ { :file_path => path, :name =>  StepFile#name } ]
        def step_files_and_names
          @step_files.map do |step_file|
            { :file_path => File.expand_path(step_file), :name => StepsFile.new(step_file).name }
          end
        end
      end

    end
  end

end
