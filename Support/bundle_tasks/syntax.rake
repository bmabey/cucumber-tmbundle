class SyntaxGenerator
  def generate
    require 'yaml'
    require 'erb'
    require 'cucumber'

    scenario_keywords_array = []
    feature_keywords_array  = []
    line_keywords_array     = []

    Cucumber.config.each do |_, words|
      scenario_keywords_array << words.delete('scenario')
      feature_keywords_array << words.delete('feature')
      line_keywords_array.concat(words.values)
    end
    
    scenario_keywords = scenario_keywords_array.uniq.join('|')
    feature_keywords  = feature_keywords_array.uniq.join('|')
    line_keywords     = line_keywords_array.uniq.join('|')

    template    = ERB.new(IO.read(File.dirname(__FILE__) + '/../../Syntaxes/plaintext_template.erb'))
    syntax      = template.result(binding)

    syntax_file = File.dirname(__FILE__) + '/../../Syntaxes/Cucumber Plain Text Feature.tmLanguage'
    File.open(syntax_file, "w") do |io|
      io.write(syntax)
    end
        
  end
end

namespace :syntax do
  desc 'Generates the plain text syntax file for all languages in languages.yml'
  task :generate do
    SyntaxGenerator.new.generate
  end
end