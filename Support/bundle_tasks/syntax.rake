desc 'Generates the plain text syntax file for all languages supported by Cucumber'
task :i18n_generate do
  require 'erb'
  require 'gherkin/i18n'

  template = ERB.new(IO.read(File.dirname(__FILE__) + '/../../Syntaxes/plaintext_template.erb'))
  File.open(File.dirname(__FILE__) + '/../../Syntaxes/Cucumber Plain Text Feature.tmLanguage', "wb") do |io|
    io.write(template.result(binding))
  end
end
