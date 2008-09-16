require 'spec/mate/story/html_formatter'
require 'cgi'

module Spec
  module Mate
    module Story

      class TextMateFormatter < HtmlFormatter
        def run_started(count)
          @output.puts <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html 
PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>Stories</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="Expires" content="-1" />
  <meta http-equiv="Pragma" content="no-cache" />
  #{js_includes('prototype', 'lowpro', 'rspec')}
  <link href="#{resource_url('rspec.css')}" rel="stylesheet" type="text/css" />
</head>
<body>
  <div id="container">
EOF
        end
        
        def collected_steps(steps)
        end

        def scenario_failed(story_title, scenario_name, err)
          truncate_length = 900
          full_message_html = err.message.length > truncate_length ? %Q{<p rel="full_message" style="display:none;">#{CGI.escapeHTML(err.message)}</p>} : nil
          truncated_message = CGI.escapeHTML(truncate(err.message, truncate_length))
          
             
          @output.puts <<-EOF
            </ul>
          </dd>
          <dt class="failure">Failure</dt>
          <dd class="exception">
            <p class="failed">#{err.class}</p>
            <p rel="message">#{truncated_message}</p>
            #{full_message_html}
            <p rel="backtrace">#{err.backtrace.map{|line| backtrace_line(line)}.join("<br />")}</p>
          </dd>
        </dl>
EOF
        end
        def run_ended
          @output.puts <<-EOF
    </div>
  </body>
</html>
EOF
        end

      protected
        def resource_url(filename)
          "file://#{ENV['TM_BUNDLE_SUPPORT']}/resource/#{filename}"
        end
        def js_includes(*js_file_names)
          js_file_names.map{|js_file_name| "<script src='#{resource_url(js_file_name)}.js' type='text/javascript'></script>"}.join("\n")
        end
        
        def backtrace_line(line)
          line.gsub(/([^:]*\.rb):(\d*)/) do
            "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
          end
        end
        
        def truncate(text, length = 30, truncate_string = "...")
          if text.nil? then return end
          l = length - truncate_string.length
          (text.length > length ? text[0...l] + truncate_string : text).to_s
        end
    
      end
  
    end
  end
end


