require 'fileutils'

module Cucumber
  module Mate

    module Files

      class InvalidFilePathError < StandardError; end
      class Base
        attr_accessor :full_file_path

        class << self
          def create_from_file_path(file_path)
            if klass_from_file_path(file_path)
              klass_from_file_path(file_path).new(file_path)
            else
              raise InvalidFilePathError, "Feature files should have suffix .feature; Step definitions should be _steps.rb"
            end
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
          @project_root ||= find_project_dir(File.dirname(full_file_path))
        end

        def relative_path
          @relative_path ||= full_file_path[project_root.length+1..-1]
        end

        def in_project_directory(&block)
          result = nil
          Dir.chdir(project_root) { result = yield }
          result
        end

        def default_file_path(kind, name = self.name)
          name = @options[kind] if @options[kind]
          replacements = {
            :steps => "/step_definitions/#{name}_steps.rb",
            :feature => "/#{name}.feature"
          }

          raise ArgumentError, "passed argument must be one of #{replacements.keys.join(', ')}"  unless replacements.has_key?(kind)
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

        def all(kind)
          in_project_directory do
            case kind.to_sym
            when :feature
              Dir['features/**/*.feature'].map { |f| FeatureFile.new(File.expand_path(f)) }
            when :steps
              Dir['features/**/*_steps.rb'].map { |f| StepsFile.new(File.expand_path(f)) }
            end
          end
        end

        def all_path_and_names(kind)
          all(kind).map {|file| {:file_path => file.full_file_path, :name => file.name} }
        end

        def feature_file_path
          file_path(:feature)
        end

        def steps_file_path
          file_path(:steps)
        end

        def name
          @name ||= full_file_path.match(%r{/([^/]*)\.\w*$}).captures.first
        end

        def feature_file?; false; end
        def steps_file?; false; end

        def ==(step_or_feature_file)
          step_or_feature_file.is_a?(self.class) && self.full_file_path == step_or_feature_file.full_file_path
        end

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

        def find_project_dir(current_dir)
          return nil unless File.exists?(current_dir)
          current_dir = File.expand_path(current_dir)
          FileUtils.chdir(current_dir) do
            parent_dir = File.expand_path("..")
            return nil if parent_dir == current_dir
            boot_file = File.join(current_dir, "features")
            return File.exists?(boot_file) ? current_dir : find_project_dir(parent_dir)
          end
        end

      end

    end

  end
end
