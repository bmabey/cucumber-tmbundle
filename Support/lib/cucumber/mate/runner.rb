require File.join(File.dirname(__FILE__), %w[.. mate])
require File.join(File.dirname(__FILE__), 'files')

module Cucumber
  module Mate
      
    class Runner
      
      def initialize(output, project_directory, full_file_path, cucumber_opts=nil)
        @file = Files::Base.create_from_file_path(full_file_path)
        @output = output
        @project_directory = project_directory
        @filename_opts = ""
        @cucumber_opts = cucumber_opts || "--format=html"
        @cucumber_opts << " --profile=#{@file.profile}" if @file.profile
      end
      
      def run_scenario(line_number)
        @filename_opts << ":#{line_number}"
        run
      end
      
      def run_feature
        run
      end

      
    protected
    
    def run
      argv = []
      if @file.rake_task
        command = "rake"
        argv << "FEATURE=#{@file.feature_file_path}"     
        argv << %Q{CUCUMBER_OPTS="#{@cucumber_opts}"}
      else
        command = File.exists?(script = "#{@project_directory}/script/cucumber") ? script : "cucumber"
        argv << "#{@file.feature_file_path}#{@filename_opts}"
        argv << @cucumber_opts
      end
      Dir.chdir(@project_directory) do        
        @output << %Q{Running: #{full_command = "#{command} #{@file.rake_task} #{argv.join(' ')}"} \n}
        @output << Kernel.system(full_command)
      end
    end

    end
    
  end
end