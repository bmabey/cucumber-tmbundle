require File.join(File.dirname(__FILE__), %w[.. mate])
require File.join(File.dirname(__FILE__), 'files')

module Cucumber
  module Mate
      
    class Runner
      
      def initialize(output, project_directory, full_file_path, cucumber_opts=nil)
        @file = Files::Base.create_from_file_path(full_file_path)
        @output = output
        @project_directory = project_directory
        @cucumber_opts = cucumber_opts || "--format=html"
      end
      
      def run_scenario(line_number)
        @cucumber_opts << " --line #{line_number}"
        run
      end
      
      def run_feature
        run
      end

      
    protected
    
    def run
      argv = []
      argv << "FEATURE=#{@file.feature_file_path}"      
      argv << %Q{CUCUMBER_OPTS="#{@cucumber_opts}"}              
      Dir.chdir(@project_directory) do
        @output << Kernel.system("rake #{@file.rake_task} #{argv.join(' ')}")
      end
    end

    end
    
  end
end