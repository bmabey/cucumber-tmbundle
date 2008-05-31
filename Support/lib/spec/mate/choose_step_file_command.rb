require "#{ENV['TM_SUPPORT_PATH']}/lib/ui.rb"

module Spec
  module Mate
    class ChooseStepFileCommand
      def file_type(path)
        [
          
          [/\.story$/,              'story'],
          [/\_steps.rb$/,           'steps file'],
          [/\/stories\/[^\.]*.rb$/, 'runner file']
          
        ].each {|pattern, file_type| return file_type if path =~ pattern}
        "file"
      end
      
      def story_runner_file_for(path)
        return unless file_type(path) == 'story'
        runner_path = path.gsub(/\/stories\/([^\.\/]*)\.story$/, '/steps/\1_steps.rb')
      end
      
      def parse_steps(content)
        $1.gsub(':', '').split(',').collect{|s| s.strip} if content =~ /with_steps_for\s*\(?(.*)\)?\s?(do|\{)/
      end
      
      def full_path_for_step_name(project_directory, step_name)
        File.expand_path(Dir["#{project_directory}/stories/**/#{step_name}_steps.rb"].first)
      end
      
      def step_files_for(project_directory, path)
        if file_type(path) == 'story'
          story_name = path.match(/\/([^\.\/]*)\.(story|txt)$/).captures.first
          steps_file_path = File.dirname(path) + "/../#{story_name}.rb"
          
          parse_steps(File.open(steps_file_path){|f| f.read})
        else
          step_files = Dir["#{project_directory}/stories/**/*_steps.rb"]
          step_files.collect{|f| f.match(/([^\/]*)_steps.rb$/).captures.first }.sort
        end
      end
      
      def list_files(project_directory, filepath)
        if step_names = step_files_for(project_directory, filepath)
          step_file_index = TextMate::UI.menu(step_names)
          exit if step_file_index.nil?
          open_file(full_path_for_step_name(project_directory, step_names[step_file_index]))
        end
      end
      
      def open_file(path)
        `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
        `"$TM_SUPPORT_PATH/bin/mate" "#{path}"`
      end
      
      
      
      # def list_files(project_directory, filepath)
      #   if step_file = choose_file
      #     full_path = "#{project_directory}/stories/steps/#{step_file}_steps.rb"
      #     open_file(full_path)
      #   end
      # end
      # 
      # 
      # def choose_file
      #   result = `#{ ENV['TM_SUPPORT_PATH'] }/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog standard-dropdown --float --exit-onchange --string-output --title "Choose step file" --text "Which step file?" --items "blah" "foo" "path"`
      #   
      #   button, choice = result.split("\n").collect{|s| s.chomp}
      #   
      #   return false if button == "Cancel"
      #   choice
      #   # answer = `#{ ENV['TM_SUPPORT_PATH'] }/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog yesno-msgbox --no-cancel --icon document --informative-text "#{relative_twin}" --text "Create missing #{file_type}?"`
      #   # answer.to_s.chomp == "1"
      # end
    end
  end
end