require File.join(File.dirname(__FILE__), %w[.. mate])
require File.join(File.dirname(__FILE__), %w[path_helper])
require File.join(File.dirname(__FILE__), %w[text_mate_helper])
require File.join(File.dirname(__FILE__), 'files')

module Cucumber
  module Mate

    class FeatureHelper
      include PathHelper

      def initialize(full_file_path)
        @full_file_path = full_file_path
        @file = Files::Base.create_from_file_path(full_file_path)
      end

      def run_feature
        argv = []
        argv << "FEATURE=#{@file.feature_file_path}"
        unless (cucumber_opts = ENV['TM_CUCUMBER_OPTS'])
          cucumber_opts = ""
          cucumber_opts << '--format'
          cucumber_opts << '=html'
        end
        argv << "CUCUMBER_OPTS=#{cucumber_opts}"

        in_project_directory do
          puts `rake features:standard #{argv.join(' ')}`
        end
      end

      def goto_alternate_file
        goto_or_create_file(@file.alternate_file_path)
      end

      def choose_alternate_file
        alternate_files_and_names = @file.alternate_files_and_names
        if (choice = TextMateHelper.display_select_list(alternate_files_and_names.collect{|h| h[:name] || h[:file_path]}))
          goto_or_create_file(alternate_files_and_names[choice][:file_path])
        end
      end

      def goto_current_step(line_number)
        return unless @file.feature_file? && step_info = @file.step_information_for_line(line_number)
        if (step_location = @file.location_of_step(step_info))
          TextMateHelper.goto_file(step_location.delete(:file_path), step_location)
        else
          goto_steps_file_with_new_steps([step_info])
        end
      end

      def goto_step_usage(line_number)

      end

      def create_all_undefined_steps
        return unless @file.feature_file? && undefined_steps = @file.undefined_steps
        goto_steps_file_with_new_steps(undefined_steps)
      end

      def autocomplete_step(stdout, current_line)
        unless matches = current_line.match(/([\s\t]*(?:given|when|then|and|but)\s+)(.*)/i)
          stdout.print current_line
          return
        end
        line_start, step_prefix = matches[1..2]
        matching_step_definitions = @file.steps_starting_with(step_prefix)
        unless matching_step_definitions && matching_step_definitions.size > 0
          stdout.print current_line
          return
        end
        if matching_step_definitions.size > 1
          patterns = matching_step_definitions.map { |step| step[:pattern_text] }
          if choice = TextMateHelper.display_select_list(patterns)
            result = convert_step_definition_regexp_groups_to_snippet_tab_stops(matching_step_definitions[choice])
            stdout.print "#{line_start}#{result}"
            return
          end
        else
          result = convert_step_definition_regexp_groups_to_snippet_tab_stops(matching_step_definitions.first)
          stdout.print "#{line_start}#{result}"
          return
        end
        stdout.print current_line
      end

    protected
      def goto_steps_file_with_new_steps(new_steps)
        steps_file = Files::StepsFile.new(@file.steps_file_path)
        goto_or_create_file(steps_file.full_file_path,
          :line => 1,
          :column => 1,
          :additional_content => Files::StepsFile.create_steps(new_steps, !File.file?(steps_file.full_file_path)))
      end

      def request_confirmation_to_create_file(file_path)
        TextMateHelper.request_confirmation(:title => "Create new file?", :prompt => "Do you want to create\n#{file_path.gsub(/^(.*?)features/, 'features')}?")
      end

      def goto_or_create_file(file_path, options = {})
        options = {:line => 1, :column => 1}.merge(options)
        additional_content = options.delete(:additional_content)

        if File.file?(file_path)
          TextMateHelper.goto_file(file_path, options)
          TextMateHelper.insert_text(additional_content) if additional_content
        elsif request_confirmation_to_create_file(file_path)
          TextMateHelper.create_and_open_file(file_path)
          TextMateHelper.insert_text(default_content(file_path, additional_content))
        end
      end

      def silently_create_file(file_path)
        TextMateHelper.create_file(file_path)
        `echo "#{Files::Base.create_from_file_path(file_path).class.default_content(file_path).gsub('"','\\"')}" > "#{file_path}"`
      end

      def default_content(file_path, additional_content)
        Files::Base.default_content_for(file_path, additional_content)
      end

      def step_regexs
        [/^I am on (.+)$/, /I go to (.+)$/, /^I press "(.*)"$/]
      end

      def convert_step_definition_regexp_groups_to_snippet_tab_stops(step_def)
        tab_stop_count = 1
        snippet_text = step_def[:pattern_text]
        while snippet_text.match(%r{\(})
          snippet_text.sub!(%r{\(([^)]+)\)}, "${#{tab_stop_count}:\\1}")
          tab_stop_count += 1
        end
        snippet_text
      end
    end

  end
end
