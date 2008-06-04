module Spec
  module Mate
    module Story
      module Files
      
        class Base
          attr_accessor :full_file_path
          
          class << self
            def create_from_file_path(file_path)
              klass_from_file_path(file_path).new(file_path)
            end
            
            def default_content_for(file_path, additional_content = nil)
              klass_from_file_path(file_path).default_content(file_path, additional_content)
            end
            
            def klass_from_file_path(file_path)
              case file_path
              when /(story|txt)$/     then StoryFile
              when /_steps\.rb$/      then StepsFile
              when /stories\/.*\.rb/  then RunnerFile
              end
            end
          end
          
          def initialize(full_file_path)
            @full_file_path = full_file_path
          end
          
          def project_root
            @project_root ||= full_file_path.gsub(/\/stories.+$/, '')
          end
          
          def relative_path
            @relative_path ||= full_file_path[project_root.length+1..-1]
          end
          
          def is_story_file?; false; end
          def is_steps_file?; false; end
          def is_runner_file?; false; end
        end
        
      end
    end
  end
end
