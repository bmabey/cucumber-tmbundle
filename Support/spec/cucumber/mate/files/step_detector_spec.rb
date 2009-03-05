require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/cucumber/mate/files'

module Cucumber
  module Mate
    module Files
    
      describe StepDetector do
        before(:each) do
          @step_detector = StepDetector.new(File.dirname(__FILE__) + "/../../../../fixtures/features/additional_basic.feature")
        end
        
        describe "#step_files_and_names" do
          before(:each) do
            @step_files_and_names = @step_detector.step_files_and_names
          end
          
          it "should return 5 files" do
            @step_files_and_names.length.should == 5
          end
          
          it "should return array of { :file_path => path }" do
            @step_files_and_names.each do |step_file_info|
              step_file_info[:file_path].should_not be_nil
              File.should be_exist(step_file_info[:file_path])
            end
          end
        end

      end
    end
  end
end

# step_files_and_names