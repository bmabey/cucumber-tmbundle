require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"

module Cucumber
  module Mate
    
    class TextMateHelper
      class << self
        def goto_file(file_path, options = {})
          TextMate.go_to(options.merge(:file => file_path))
        end
        
        def display_select_list(options)
          TextMate::UI.menu(options)
        end
        
        def alert(options = {})
          options = {:message => options} if options.kind_of?(String)
          options = {:style => :informational, :title => 'Alert!', :message => '', :buttons => 'OK'}.merge(options)
          TextMate::UI.alert(options[:style], options[:title], options[:message], options[:buttons])
        end
        
        def request_confirmation(options)
          TextMate::UI.request_confirmation(options)
        end
        
        def create_file(file_path)
          `mkdir -p "#{File.dirname(file_path)}"`
          `touch "#{file_path}"`
        end
        
        def create_and_open_file(file_path)
          create_file(file_path)
          `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
          `"$TM_SUPPORT_PATH/bin/mate" "#{file_path}"`
        end
        
        def insert_text(text)
          `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
          escaped_content = text.gsub("\n","\\n").gsub('$','\\$').gsub('"','\\\\\\\\\\\\"')
          `osascript &>/dev/null -e "tell app \\"TextMate\\" to insert \\"#{escaped_content}\\" as snippet true"`
        end
      end
    end
    
  end
end