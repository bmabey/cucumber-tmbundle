require File.join(File.dirname(__FILE__), %w[.. mate])
require File.join(File.dirname(__FILE__), 'files')

module Cucumber
  module Mate

    class Runner
      CUCUMBER_BIN = %x{which cucumber}.chomp
      RUBY_BIN = ENV['TM_RUBY'] || %x{which ruby}.chomp
      RAKE_BIN = %x{which rake}.chomp
      
      def initialize(output, project_directory, full_file_path, cucumber_bin = nil, cucumber_opts=nil)
        @file = Files::Base.create_from_file_path(full_file_path)
        @output = output
        @project_directory = project_directory
        @filename_opts = ""
        @cucumber_bin = cucumber_bin || CUCUMBER_BIN
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
      
      def autoformat_feature
        in_project_dir do
          Kernel.system("#{cucumber_cmd} --autoformat . #{@file.relative_path}")
        end
      end


    protected

      def run
        argv = []
        if @file.rake_task
          command = RAKE_BIN
          argv << "FEATURE=#{@file.full_file_path}"
          argv << %Q{CUCUMBER_OPTS="#{@cucumber_opts}"}
        else
          command = cucumber_cmd
          argv << "#{@file.full_file_path}#{@filename_opts}"
          argv << @cucumber_opts
        end
        in_project_dir do
          @output << %Q{Running: #{full_command = "#{RUBY_BIN} #{command} #{@file.rake_task} #{argv.join(' ')}"} \n}
          @output << Kernel.system(full_command)
        end
      end
      
      def cucumber_cmd
        File.exists?(script = "#{@project_directory}/script/cucumber") ? script : @cucumber_bin
      end

      def in_project_dir(&block)
        Dir.chdir(@project_directory, &block)
      end

    end

  end
end
