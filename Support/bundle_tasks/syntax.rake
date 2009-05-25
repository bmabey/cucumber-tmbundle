class SyntaxGenerator
  def generate
    require 'yaml'
    require 'erb'
    require 'cucumber'

    scenario_keywords_array = []
    scenario_outline_keywords_array = []
    feature_keywords_array  = []
    line_keywords_array     = []

    Cucumber::LANGUAGES.each do |_, words|
      scenario_keywords_array << words.delete('scenario')
      feature_keywords_array << words.delete('feature')
      scenario_outline_keywords_array << words.delete('scenario_outline')

      # Remove words we're not interested in
      %w{name native encoding space_after_keyword}.each{|key| words.delete(key)}

      line_keywords_array.concat(words.values)
    end
    
    scenario_keywords = scenario_keywords_array.uniq.compact.sort.join('|')
    scenario_outline_keywords = scenario_outline_keywords_array.uniq.compact.sort.join('|')
    feature_keywords  = feature_keywords_array.uniq.compact.sort.join('|')
    line_keywords     = line_keywords_array.uniq.compact.sort.join('|')

    template    = ERB.new(IO.read(File.dirname(__FILE__) + '/../../Syntaxes/plaintext_template.erb'))
    syntax      = template.result(binding)

    syntax_file = File.dirname(__FILE__) + '/../../Syntaxes/Cucumber Plain Text Feature.tmLanguage'
    File.open(syntax_file, "w") do |io|
      io.write(syntax)
    end
        
  end
end

namespace :syntax do
  desc 'Generates the plain text syntax file for all languages supported by Cucumber'
  task :generate do
    SyntaxGenerator.new.generate
  end
end
