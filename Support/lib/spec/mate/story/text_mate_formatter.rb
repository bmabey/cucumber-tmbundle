require 'spec/runner/formatter/story/html_formatter'


module Spec
  module Mate
    module Story

      class TextMateFormatter < Spec::Runner::Formatter::Story::HtmlFormatter
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
  <link href="#{resource_url('rspec.css')}" rel="stylesheet" type="text/css" />
</head>
<body>
  <div id="container">
EOF
        end
        
        def collected_steps(steps)
        end

        def scenario_failed(story_title, scenario_name, err)
          @output.puts <<-EOF
            </ul>
          </dd>
          <dt>Failure</dt>
          <dd>
            #{err.class}: #{err.message}<br />
            #{err.backtrace.map{|line| backtrace_line(line)}.join("<br />")}
          </dd>
        </dl>
EOF
        end

      protected
        def resource_url(filename)
          "file://#{ENV['TM_BUNDLE_SUPPORT']}/resource/#{filename}"
        end
        
        def backtrace_line(line)
          line.gsub(/([^:]*\.rb):(\d*)/) do
            "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
          end
        end
    
      end
  
    end
  end
end


