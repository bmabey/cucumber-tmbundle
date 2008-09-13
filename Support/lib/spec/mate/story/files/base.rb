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
            @options = parse_options
          end
          
          def project_root
            @project_root ||= full_file_path.gsub(/\/stories.+$/, '')
          end
          
          def relative_path
            @relative_path ||= full_file_path[project_root.length+1..-1]
          end
          
          def default_file_path(kind, name = self.name)
            name = @options[kind] if @options[kind]
            replacements = {
              :steps => "/steps/#{name}_steps.rb",
              :story => "/stories/#{name}.story",
              :runner => "/#{name}.rb"
            }
            
            raise ArgumentError, "passed argument must be one of #{replacements.keys.join(', ')}"  unless replacements.has_key?(kind)
            
            full_file_path.gsub(%r<(/stories/#{name}\.(story|txt))|((/[^/])?(/steps)?/#{name}(_\w*)?\.rb)>, replacements[kind])
          end
          
          def file_path(kind, name = self.name)
            name = @options[kind] if @options[kind]
            search_paths = {
              :steps => "#{project_root}/stories/**/#{name}_steps.rb",
              :story => "#{project_root}/stories/**/#{name}.{story,txt}",
              :runner => "#{project_root}/stories/**/#{name}.rb"
              }
            
            raise ArgumentError, "passed argument must be one of #{search_paths.keys.join(', ')}"  unless search_paths.has_key?(kind)
            
            Dir[search_paths[kind]].first || default_file_path(kind)
          end
          
          def method_missing(meth)
            raise NoMethodError, "Invalid method #{meth}" unless md = meth.to_s.match(/(.+)_file_path$/)
            file_path(md.captures.first.to_sym)
          end
          
          def name
            @name ||= full_file_path.match(/\/([^\/]*)\.\w*$/).captures.first
          end
          
          def is_story_file?; false; end
          def is_steps_file?; false; end
          def is_runner_file?; false; end
          
        private
          def parse_options
            return {} unless File.file?(full_file_path)
            first_line = File.open(full_file_path) {|f| f.readline unless f.eof} || ''
            return {} unless first_line.match(/\s*#\s*(.+:.+)/)
            $1.split(',').inject({}) do |hash, pair|
              k,v = pair.split(':')
              hash[k.strip.to_sym] = v.strip if k && v
              hash
            end
          end
        end
        
      end
    end
  end
end
