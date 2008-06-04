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
          
          def name
            @name ||= full_file_path.match(/\/([^\/]*)\.rb$/).captures.first
          end
          
          def story_file_path
            @story_file_path ||= find_story_file
          end
          
          def steps_file_path
            @steps_file_path ||= full_file_path.gsub(%r</#{name}\.rb$>, "/steps/#{name}_steps.rb")
          end
          
          def alternate_files_and_names
            [{:name => "#{name.gsub('_', ' ')} story", :file_path => story_file_path}] + step_files_and_names
          end
          
          def step_files_and_names
            step_names.collect do |name|
              steps_file_file_path =  if (first_found_file = Dir["#{project_root}/stories/**/steps/#{name}_steps.rb"].first)
                                        first_found_file
                                      else
                                        "#{project_root}/stories/steps/#{name}_steps.rb"
                                      end
              {:name => "#{name.to_s.gsub('_', ' ')} steps", :file_path => steps_file_file_path}
            end
          end
        protected
          def find_story_file
            file_path = ''
            %w(txt story).each do |ext|
              file_path = full_file_path.gsub(%r</#{name}\.rb$>, "/stories/#{name}.#{ext}")
              return file_path if File.file?(file_path)
            end
            file_path
          end
          
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
