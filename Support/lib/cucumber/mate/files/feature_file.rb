require File.join(File.dirname(__FILE__), %w[.. path_helper])
module Cucumber
  module Mate

    module Files

      class FeatureFile < Base
        class << self
          include PathHelper

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
          all_path_and_names(:steps)
        end

        alias :alternate_files_and_names :step_files_and_names

        # Returns the name of a step at a specific line number
        # e.g. if the step on the target line is: Given a logged in user
        # then the result would be: { :step_name => "a logged in user" }
        def step_information_for_line(line_number)
          line_index = line_number.to_i-1

          line_text = content_lines[line_index]
          return unless line_text && line_text.strip!.match(/^(given|when|then|and)(.*)/i)
          step_type = $1.capitalize
          source_step_name = $2.strip
          if step_type == "And"
            content_lines[0..(line_index - 1)].reverse.detect do |line|
              if line.match(/^\s*(given|when|then)(.*)/i)
                step_type = $1.capitalize
              end
            end
          end

          return {:step_name => source_step_name, :step_type => step_type}
        end

        # Right now will return first matching step
        # Ultimately used by TextMateHelper.goto_file
        # Returns a hash with keys: :file_path, :line, :pattern, :pattern_text
        def location_of_step(step_info)
          all_defined_steps.each do |step_def|
            if step_def[:pattern].is_a?(Regexp)
              pattern = step_def[:pattern]
            else
              pattern = %r(^#{Regexp.escape(step_def[:pattern].gsub(/\$\w+/, "STRING_MATCHER_TOKEN")).gsub("STRING_MATCHER_TOKEN", "(.+)")}$)
            end
            return step_def if pattern =~ step_info[:step_name]
          end
          nil
        end

        def steps_starting_with(step_prefix)
          step_prefix_regex = /^#{step_prefix}/
          all_defined_steps.select do |step_def|
            step_def[:pattern_text] =~ step_prefix_regex
          end
        end

        def undefined_steps
          all_steps_in_file.inject([]) do |undefined_steps, step_info|
            unless location_of_step(step_info) || undefined_steps.any?{|s| s[:step_name] == step_info[:step_name] }
              undefined_steps << step_info
            end
            undefined_steps
          end
        end

      protected
        def all_steps_in_file
          file_lines = File.read(full_file_path).split("\n").collect{|l| l.strip}

          file_lines.inject([]) do |text_steps, line|
            step_type = $1 if line.match(/^(Given|When|Then)\s+/)
            text_steps << {:step_type => step_type, :step_name => $2} if line.match(/^(Given|When|Then|And)\s+(.*)$/)
            text_steps
          end
        end

        def content_lines
          @content_lines ||= File.read(full_file_path).split("\n")
        end

        # Returns an array of hashes, each describing a Given/When/Then step defined in this step file
        # Each hash-per-step has the keys: :file_path, :line, :pattern, :pattern_text
        def all_defined_steps
          @defined_steps ||= step_files_and_names.inject([]) do |mem, step_file_info|
            StepsFile.new(step_file_info[:file_path]).step_definitions.each do |step_def|
              mem << step_def
            end
            mem
          end
        end
      end

    end

  end
end
