require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/cucumber/mate/runner'

module Cucumber
  module Mate
    
    describe "a run command", :shared => true do
      
      before(:each) do
        Files::Base.stub!(:create_from_file_path).and_return(
          @file = mock("feature file", :rake_task => 'some_task', :feature_file_path => 'path_to_feature.feature'))
        Dir.stub!(:chdir).and_yield
        Kernel.stub!(:system)
      end
      
      def expect_system_call_to_be_made_with(regex)
        Kernel.should_receive(:system).with(regex)
      end
      
      it "should run the file's rake task" do
        expect_system_call_to_be_made_with(/^rake #{@file.rake_task} /)
        when_run_is_called
      end
      
      it "should run the single feature" do
        expect_system_call_to_be_made_with(/FEATURE=#{@file.feature_file_path}/)
        when_run_is_called
      end
      
      it "should run with the deafult cucumber options when none are passed in" do
        expect_system_call_to_be_made_with(/CUCUMBER_OPTS="--format=html/)
        when_run_is_called
      end
      
      it "should run with the cucumber options passed in" do
        expect_system_call_to_be_made_with(/CUCUMBER_OPTS="--format=custom/)
        when_run_is_called("--format=custom")
      end
      
      it "should direct the rake's output to the passed in output" do
        Kernel.stub!(:system).and_return("features html")
        output = when_run_is_called
        output.string.should == "features html"
      end
      
    end
    
    describe Runner do
      
      it "should create a new Files::Base from the passed in file path" do
        # expect
        Files::Base.should_receive(:create_from_file_path).with("/path/to/file")
        # when
        Runner.new(nil, "/path","/path/to/file")
      end      
    
      describe "#run_feature" do
        
        def when_run_feature_is_called(cucumber_options=nil)
          Runner.new(output=StringIO.new, "/project/path", "/project/path/feature_file", cucumber_options).run_feature
          output
        end
        alias :when_run_is_called :when_run_feature_is_called
        
        it_should_behave_like "a run command"
        
      end
      
      describe "#run_scenario" do
        
        def when_run_scenario_is_called(cucumber_options=nil)
          Runner.new(output=StringIO.new, "/project/path", "/project/path/feature_file", cucumber_options).run_scenario(12)
          output
        end
        alias :when_run_is_called :when_run_scenario_is_called
        
        it_should_behave_like "a run command"
                      
        it "should pass the line number to the rake task" do
          # given
          runner = Runner.new(output=StringIO.new, "/project/path", "/project/path/feature_file")
          
          expect_system_call_to_be_made_with(/CUCUMBER_OPTS="--format=html --line 42"/)
          
          # when
          runner.run_scenario(42)
        end
        
      end
      
      
    end
    
  end
end