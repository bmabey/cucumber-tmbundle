require 'rubygems'

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
              steps_so_far[current_step_info[:step_type] || 'Then'] << current_step_info[:step_name]
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
          all_path_and_names(:feature)
        end

        alias :alternate_files_and_names :feature_files_and_names

        # Returns an array of hashes, each describing a Given/When/Then step defined in this step file
        # Each hash-per-step has the keys: :file_path, :line, :pattern, :pattern_text
        def step_definitions
          if File.file?(full_file_path)
            @steps = []
            @file_contents = File.read(full_file_path)
            lines = @file_contents.split("\n")
            lines.each do |line|
              case line
              when /\s*(When|Given|Then).+do\s*(\|[^\|]+\|){0,1}\s*(#.+|$)/
                line.gsub!($3, "") if $3
                line << "; end"
              when /\s*(When|Given|Then)\s*\(.+\)\s*\{\s*.+\s*\}\s*(#.+|$)/
              when /\s*(When|Given|Then)\s*\(.+\)\s*\{\s*(\|[^\|]+\|){0,1}\s*(#.+|$)/
                line.gsub!(/#[^#]+$/, '') if $2
                line << "}"
              else
                line.insert(0, "# ")
              end
            end
            @file_contents = lines * "\n"
            instance_eval(@file_contents, full_file_path, 1)
            @steps
          else
            []
          end
        end

      protected
        # While evaluating step definitions code - This called when a new step has been parse
        # We need to save these to be able to match plain text
        def add_step(type, pattern)
          line_number = caller[1].match(/:(\d+)/).captures.first.to_i

          @steps << {:pattern => pattern, :line => line_number,
                      :pattern_text => (pattern.is_a?(Regexp) ? pattern.source.gsub('^', '') : pattern),
                      :file_path => full_file_path}
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
        
        def World(helpers)
        end
        
        def After
        end
        
        def Before
        end
        
        def at_exit
        end
      end

    end

  end
end
