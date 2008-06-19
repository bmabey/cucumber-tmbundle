require 'rubygems'
require 'spec'

module Spec::Example::ExampleMethods
  def project_root
    @project_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../fixtures'))
  end
end