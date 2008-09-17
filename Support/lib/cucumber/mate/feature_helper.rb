require File.join(File.dirname(__FILE__), %w[.. mate])
require File.join(File.dirname(__FILE__), %w[text_mate_helper])
require File.join(File.dirname(__FILE__), 'files')

module Cucumber
  module Mate
      
    class FeatureHelper
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
                
        Dir.chdir(full_project_directory) do
          puts `rake features:standard #{argv.join(' ')}`
        end
      end
      
      def goto_alternate_file
        goto_or_create_file(@file.alternate_file_path)
      end
      
      def choose_alternate_file
        alternate_files_and_names = @file.alternate_files_and_names
        if (choice = TextMateHelper.display_select_list(alternate_files_and_names.collect{|h| h[:name]}))
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
      
      def create_all_undefined_steps
        return unless @file.feature_file? && undefined_steps = @file.undefined_steps
        goto_steps_file_with_new_steps(undefined_steps)
      end
      
    protected
      def goto_steps_file_with_new_steps(new_steps)
        silently_create_file(@file.runner_file_path) if !File.file?(@file.runner_file_path) && request_confirmation_to_create_file(@file.runner_file_path)
        steps_file = Files::StepsFile.new(@file.steps_file_path)
        goto_or_create_file(steps_file.full_file_path,
          :line => steps_file.new_steps_line_number,
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
      
      def full_project_directory
        #TODO: get rid of global
        File.expand_path(ENV['TM_PROJECT_DIRECTORY'])
      end
    end
    
  end
end