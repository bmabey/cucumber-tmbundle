module Spec
  module Mate
    module Story
      module Files
      
        class RunnerFile < Base
          class << self
            def default_content(file_path, additional_content = nil)
              story_name = file_path.match(/([^\/]*).rb$/).captures.first
              num_paths_up = file_path.match(/^.*?\/stories\/(.*)$/).captures.first.split('/').size - 1
              content = <<-EOF
require File.join(File.dirname(__FILE__).gsub(/stories(.*)/,"stories"),"helper")

with_steps_for :#{story_name} do
  run_story(File.expand_path(__FILE__))
end
EOF
            end
          end
          
          def is_runner_file?; true; end
          
          def alternate_files_and_names
            [{:name => "#{name.gsub('_', ' ')} story", :file_path => story_file_path}] + step_files_and_names
          end
          
          def step_files_and_names
            step_names.collect do |step_name|
              {:name => "#{step_name.to_s.gsub('_', ' ')} steps", :file_path => file_path(:steps, step_name)}
            end
          end
        protected
          def step_names
            if File.file?(full_file_path)
              content = File.read(full_file_path)
              with_steps_regexp = /.*with_steps/m
              
              return [] unless content.match(with_steps_regexp)
              content.gsub!(with_steps_regexp, 'with_steps')
              eval(content).collect{|step_tag| step_tag.to_s}
            else
              [name]
            end
          end
          
          def with_steps_for(*args)
            return args.kind_of?(Array) ? args : [args]
          end
        end
        
      end
    end
  end
end
