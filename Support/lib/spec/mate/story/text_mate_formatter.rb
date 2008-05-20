require 'spec/runner/formatter/story/html_formatter'


module Spec
  module Mate
    module Story

      class TextMateFormatter < Spec::Runner::Formatter::Story::HtmlFormatter
        include ERB::Util
        
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
  <link href="file:///Users/bmabey/w/ah/dc/vendor/plugins/rspec/story_server/prototype/stylesheets/rspec.css" rel="stylesheet" type="text/css" />
</head>
<body>
  <div id="container">
EOF
        end
        
    
      end
  
    end
  end
end


