require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"

module Spec
  module Mate
    class TextMateHelper
      
      class << self
        def open_or_prompt(file_path, options = {})
          new.open_or_prompt(file_path, options)
        end
        
        def snippet_text_for(snippet_name, *replacements)
          new.snippet_text_for(snippet_name, replacements)
        end
        
        def insert_text(text)
          new.insert_text(text)
        end
      end
      
      def snippet_text_for(snippet_name, *replacements)
        snippet_file = File.expand_path(File.dirname(__FILE__) + "/../../../../Snippets/#{snippet_name}.tmSnippet")
        content = File.read(snippet_file).match(/<key>content<\/key>\s*<string>([^<]*)<\/string>/m)[1]
        if replacements
          replacements.each_with_index do |replacement,index|
            snippet_index = index+1
            content.gsub!(/\$\{#{snippet_index}:([^\}]*)/, "${#{snippet_index}:#{replacement}")
          end
        end
        content
      end
      
      def insert_text(text)
        `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
        escaped_content = text.gsub("\n","\\n").gsub('$','\\$').gsub('"','\\\\\\\\\\\\"')
        `osascript &>/dev/null -e "tell app \\"TextMate\\" to insert \\"#{escaped_content}\\" as snippet true"`
      end
      
      def open_or_prompt(file_path, options = {})
        {:line_number => 1, :column_number => 1}.merge(options)
        if File.file?(file_path)
          TextMate.go_to(:file => file_path, :line => options[:line_number], :column => options[:column_number])
          return
        elsif TextMate::UI.request_confirmation(:title => "Create new file?", :prompt => "Do you want to create\n#{file_path.gsub(/^(.*?)stories/, 'stories')}?")
          #TextMate.go_to(:file => file_path, :line => options[:line_number], :column => options[:column_number])
          create_and_open(file_path)
          return true
        end
        false
      end  
    
    protected
      def create_and_open(file_path)
        `mkdir -p "#{File.dirname(file_path)}"`
        `touch "#{file_path}"`
        `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
        `"$TM_SUPPORT_PATH/bin/mate" "#{file_path}"`
      end
    end
  end
end