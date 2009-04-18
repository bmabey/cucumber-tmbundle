$:.unshift(File.dirname(__FILE__) + '/../../rspec/lib')
require 'rubygems'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['Support/spec/**/*_spec.rb']
  t.rcov = true
  t.spec_opts = ['--colour', '--diff']
  t.rcov_opts = ['--exclude', 'TextMate.app,gem,rspec\/plugins,rspec\/lib\/spec,spec\/spec,fixtures,bin\/spec']
end

task :default => :spec

Dir['Support/bundle_tasks/**/*.rake'].each { |rake| load rake }
