class SyntaxGenerator
  def generate
    require 'erb'
    require 'gherkin/i18n'

    template    = ERB.new(IO.read(File.dirname(__FILE__) + '/../../Syntaxes/plaintext_template.erb'))
    syntax      = template.result(binding)

    syntax_file = File.dirname(__FILE__) + '/../../Syntaxes/Cucumber Plain Text Feature.tmLanguage'
    File.open(syntax_file, "w") do |io|
      io.write(syntax)
    end
  end
  
  def escape(s)
    s.gsub(/'/, "\\\\'").gsub(/\*/, "\\\\*")
  end
end

desc 'Generates the plain text syntax file for all languages supported by Cucumber'
task :generate do
  SyntaxGenerator.new.generate
end
