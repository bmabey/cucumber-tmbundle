require 'spec/mate/story/text_mate_formatter'
module Spec
  module Mate
    module Story

      class Runner
    
        def run_file
          run single_file
        end
        
        # def run_files(stdout, options={})
        #   files = ENV['TM_SELECTED_FILES'].split(" ").map do |path|
        #     File.expand_path(path[1..-2])
        #   end
        #   options.merge!({:files => files})
        #   run(stdout, options)
        # end
        

        protected
        
        def run(*files)
          argv = ""
          argv << '--format'
          argv << '=Spec::Mate::Story::TextMateFormatter'
          argv += ENV['TM_RSPEC_STORY_OPTS'].split(" ") if ENV['TM_RSPEC_STORY_OPTS']
          $rspec_options = Spec::Runner::OptionParser.parse(argv, STDERR, STDOUT)
          
          files.each do |file|
             to_require = file.gsub(/(.*\/)(.*).rb/,'\1stories/\2.txt')
             story_root, feature_path, story_ext = file.match(/([\w\/]*?\/stories\/)([\w\/]*).(\w*)/i).captures
             feature_root, story_name = feature_path.match(/([\w\/]*?)\/?stories\/([\w\/]*)/i).captures
             to_require = story_root + feature_root + "/#{story_name}.rb"
             require to_require
          end
        end
        
        def single_file
          File.expand_path(ENV['TM_FILEPATH'])
        end

        def project_directory
          File.expand_path(ENV['TM_PROJECT_DIRECTORY'])
        end
    
      end
  
    end
  end
end
