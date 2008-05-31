module Spec
  module Mate
    # This is based on Ruy Asan's initial code:
    # http://ruy.ca/posts/6-A-simple-switch-between-source-and-spec-file-command-for-textmate-with-auto-creation-
    class SwitchCommand
      def go_to_twin(project_directory, filepath)
        other = twin(filepath)
        if File.file?(other)
          %x{ "$TM_SUPPORT_PATH/bin/mate" "#{other}" }
        else
          relative = other[project_directory.length+1..-1]
          file_type = file_type(other)
          if create?(relative, file_type)
            content = content_for(file_type, filepath)
            write_and_open(other, content)
          end
        end
      end
    
      def twin(path)
        if path =~ /^(.*)\/(steps|stories)\/(.*?)$/
          prefix, parent, rest = $1, $2, $3
          
          case parent
            when 'steps' then
              path = path.gsub(/\/steps\//, '/stories/')
              path = path.gsub(/_steps\.rb$/, '.story')
            when 'stories' then
              path = path.gsub(/\/stories\/([^\/]*)\.(story|txt)$/, '/steps/\1_steps.rb')
          end
          return path
        end
      end
    
      def file_type(path)
        if path =~ /\.story$/
          return 'story'
        end
        if path =~ /_steps\.rb$/
          return 'steps file'
        end
        "file"
      end
    
      def create?(relative_twin, file_type)
        answer = `#{ ENV['TM_SUPPORT_PATH'] }/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog yesno-msgbox --no-cancel --icon document --informative-text "#{relative_twin}" --text "Create missing #{file_type}?"`
        answer.to_s.chomp == "1"
      end

      def content_for(file_type, filepath)
        case file_type
          when /story$/ then
            story(filepath)
          else
            steps(filepath)
        end
      end
      
      # Extracts the snippet text
      def snippet(snippet_name)
        snippet_file = File.expand_path(File.dirname(__FILE__) + "/../../../../Snippets/#{snippet_name}")
        xml = File.open(snippet_file).read
        xml.match(/<key>content<\/key>\s*<string>([^<]*)<\/string>/m)[1]
      end
      
      def story(filepath)
        snippet('Story.tmSnippet')
      end

      def steps(filepath)
        filepath =~ /([^\/]*).story/
        content = <<-STEPS
steps_for(:${1:#{$1}}) do
  Given "${2:condition}" do
    $0
  end
end
STEPS
      end
    
      def write_and_open(path, content)
        `mkdir -p "#{File.dirname(path)}"`
        `touch "#{path}"`
        `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
        `"$TM_SUPPORT_PATH/bin/mate" "#{path}"`
        escaped_content = content.gsub("\n","\\n").gsub('$','\\$').gsub('"','\\\\\\\\\\\\"')
        `osascript &>/dev/null -e "tell app \\"TextMate\\" to insert \\"#{escaped_content}\\" as snippet true"`      
      end
    end
  end
end
