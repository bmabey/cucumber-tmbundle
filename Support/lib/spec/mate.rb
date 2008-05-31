# This is based on the official RSpec tm-bundle
require 'rubygems'

rspec_rails_plugin = File.join(ENV['TM_PROJECT_DIRECTORY'],'vendor','plugins','rspec','lib')
rpsec_home = ""
if File.directory?(rspec_rails_plugin)
  $:.reject! { |e| e.include? 'TextMate' } # Fix to get around rails and TM's builder.rb clobering eachother
  $LOAD_PATH.unshift(rspec_rails_plugin)
elsif ENV['TM_RSPEC_HOME']
  rspec_lib = File.join(ENV['TM_RSPEC_HOME'], 'lib')
  unless File.directory?(rspec_lib)
    raise "TM_RSPEC_HOME points to a bad location: #{ENV['TM_RSPEC_HOME']}"
  end
  $LOAD_PATH.unshift(rspec_lib)
end
require 'spec'

$LOAD_PATH.unshift(ENV['TM_BUNDLE_SUPPORT'] + "/lib")
require "spec/mate/story/runner"
require "spec/mate/story/story_helper"
require "spec/mate/text_mate_helper"

