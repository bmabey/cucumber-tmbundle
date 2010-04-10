# This is based on the official RSpec tm-bundle
require 'rubygems'

if ENV['TM_PROJECT_DIRECTORY']
  rspec_rails_plugin = File.join(ENV['TM_PROJECT_DIRECTORY'],'vendor','plugins','rspec','lib')
  rspec_merb_gem = (merb_dir = (Dir["#{ENV['TM_PROJECT_DIRECTORY']}/gems/gems/rspec*"].first || '')) && File.join(merb_dir, "lib")
  bundler_gemfile = File.join(ENV['TM_PROJECT_DIRECTORY'], 'Gemfile')
  if File.exists?(bundler_gemfile)
    bundle_path = (File.read(bundler_gemfile) =~ (/bundle_path[ (]+['"](.*?)['"]/) && $1) || ".bundle"
    require File.join(ENV['TM_PROJECT_DIRECTORY'], bundle_path, "environment")
  elsif File.directory?(rspec_rails_plugin)
    $LOAD_PATH.unshift(rspec_rails_plugin)
  elsif File.directory?(rspec_merb_gem)
    $LOAD_PATH.unshift(rspec_merb_gem)
  elsif ENV['TM_RSPEC_HOME']
    rspec_lib = File.join(ENV['TM_RSPEC_HOME'], 'lib')
    unless File.directory?(rspec_lib)
      raise "TM_RSPEC_HOME points to a bad location: #{ENV['TM_RSPEC_HOME']}"
    end
    $LOAD_PATH.unshift(rspec_lib)
  end
end
require 'spec'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..')))
require "cucumber/mate/feature_helper"
require "cucumber/mate/runner"