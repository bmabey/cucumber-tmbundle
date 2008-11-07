module Cucumber
  module Mate
    
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
            when /feature$/         then FeatureFile
            when /_steps\.rb$/      then StepsFile
            end
          end
        end
        
        def initialize(full_file_path)
          @full_file_path = full_file_path
          @options = parse_options
        end
        
        def project_root
          @project_root ||= full_file_path.gsub(/\/features.+$/, '')
        end
        
        def relative_path
          @relative_path ||= full_file_path[project_root.length+1..-1]
        end
        
        def default_file_path(kind, name = self.name)
          name = @options[kind] if @options[kind]
          replacements = {
            :steps => "/step_definitions/#{name}_steps.rb",
            :feature => "/#{name}.feature"
          }
          
          raise ArgumentError, "passed argument must be one of #{replacements.keys.join(', ')}"  unless replacements.has_key?(kind)
          #require 'ruby-debug'; Debugger.start; debugger if kind == :feature
          full_file_path.gsub(%r<(/#{name}\.(feature|txt))|((/[^/])?(/steps)?/#{name}(_\w*)?\.rb)>, replacements[kind])
        end
        
        def file_path(kind, name = self.name)
          name = @options[kind] if @options[kind]
          search_paths = {
            :steps => "#{project_root}/features/**/#{name}_steps.rb",
            :feature => "#{project_root}/features/**/#{name}.{feature,txt}"
            }
          
          raise ArgumentError, "passed argument must be one of #{search_paths.keys.join(', ')}"  unless search_paths.has_key?(kind)
          
          Dir[search_paths[kind]].first || default_file_path(kind)
        end
        
        def feature_file_path
          file_path(:feature)
        end
        
        def steps_file_path
          file_path(:steps)
        end        
        
        def name
          @name ||= full_file_path.match(/\/([^\/]*)\.\w*$/).captures.first
        end
        
        def feature_file?; false; end
        def steps_file?; false; end
        
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
