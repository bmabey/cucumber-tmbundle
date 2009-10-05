require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "tempfile"

module Cucumber
  module Mate

    class TextMateHelper
      class << self
        # Opens target file_path and sets cursor position
        # options:
        #   :line   - line number (default: ENV['TM_LINE_NUMBER'])
        #   :column - column number (default: 1)
        def goto_file(file_path, options = {})
          TextMate.go_to(options.merge(:file => file_path))
        end

        def display_select_list(options)
          ninja_search = "/Applications/NinjaSearch.app/Contents/MacOS/NinjaSearch"
          list = options
          if list.size > too_many_to_select && File.exists?(ninja_search)
            data = list.join("\n") # TODO escape single quotes OR store in file
            res = nil
            Tempfile.open("ninjasearch-cucumber") do |f|
              f << data
              f.flush
              res = %x{NINJA_DATA='#{f.path}' #{e_sh ninja_search}  2>/dev/console}
            end
            list.index(res.strip)
          else
            TextMate::UI.menu(list)
          end
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
        
        def too_many_to_select
          9
        end
      end
    end

  end
end
