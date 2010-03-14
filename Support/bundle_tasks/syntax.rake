class SyntaxGenerator
  def generate
    require 'yaml'
    require 'erb'
    require 'gherkin'

    feature_keywords_array  = []
    scenario_keywords_array = []
    examples_keywords_array = []
    step_keywords_array     = []

    Gherkin::I18n.all.each do |lang|
      feature_keywords_array << lang.feature_keywords

      scenario_keywords_array << lang.scenario_keywords
      scenario_keywords_array << lang.scenario_outline_keywords
      scenario_keywords_array << lang.background_keywords
      scenario_keywords_array << lang.examples_keywords

      step_keywords_array << lang.step_keywords
    end
    
    feature_keywords  = escape(feature_keywords_array.flatten.compact.sort.reverse.uniq.join('|'))
    scenario_keywords = escape(scenario_keywords_array.flatten.compact.sort.reverse.uniq.join('|'))
    step_keywords     = escape(step_keywords_array.flatten.compact.sort.reverse.uniq.join('|'))

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
