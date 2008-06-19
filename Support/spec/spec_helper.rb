require 'rubygems'
require 'spec'

ENV['TM_SUPPORT_PATH'] = '/Applications/TextMate.app/Contents/SharedSupport/Support'

module Spec::Example::ExampleMethods
  def project_root
    @project_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../fixtures'))
  end
end