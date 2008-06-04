require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../../lib/spec/mate/story/files'

module Spec
  module Mate
    module Story
      module Files
      
        describe StoryFile do
          before(:each) do
            @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. .. fixtures]))
            @story_file = StoryFile.new(File.expand_path(File.join(@fixtures_path, %w[stories stories basic.story])))
          end
          
          it "should determine the runner file" do
            @story_file.runner_file_path.should == "#{@fixtures_path}/stories/basic.rb"
          end
          
          it "should determine the steps file" do
            @story_file.steps_file_path.should == "#{@fixtures_path}/stories/steps/basic_steps.rb"
          end
          
          it "should determine the correct alternate file" do
            @story_file.alternate_file_path.should == @story_file.steps_file_path
          end
          
          describe "#name" do
            it "should return the simple name (based off the file name)" do
              @story_file.name.should == 'basic'
            end
          end
          
          describe "#alternate_files_and_names" do
            before(:each) do
              RunnerFile.stub!(:new).and_return(mock('runner file', :step_files_and_names => [{:name => 'foo', :file_path => '/path/to/foo'}]))
            end
            
            it "should generate a list of steps files included in the runner file" do
              @story_file.alternate_files_and_names.should == [{:name => 'foo', :file_path => '/path/to/foo'}]
            end
          end
          
          describe "#step_information_for_line" do
            it "should not return anything if the line doesn't contain a valid step" do
              @story_file.step_information_for_line(5).should == nil
            end
            
            it "should return the step information if the line contains a valid step" do
              @story_file.step_information_for_line(8).should == {:step_type => 'Given', :step_name => 'Basic step (given)'}
            end
            
            it "should return the correct step type if the step type is 'And'" do
              @story_file.step_information_for_line(9).should == {:step_type => 'Given', :step_name => 'another basic step'}
            end
          end
          
          describe "#location_of_step" do
            describe "when the step definition exists" do
              before(:each) do
                RunnerFile.stub!(:new).and_return(@runner = mock('runner file', :step_files_and_names => [{:name => 'basic', :file_path => '/path/to/basic'}]))
                StepsFile.stub!(:new).and_return(@steps = mock('steps file', :step_definitions => [{:step => @step = mock('step', :matches? => true), :type => 'Given', :pattern => "string pattern", :line => 3, :column => 5, :file_path => '/path/to/steps', :group_tag => 'basic'}]))
              end
              
              it "should return the correct file, line and column" do
                @story_file.location_of_step({:step_type => 'Given', :step_name => 'string pattern'}).should ==
                  {:step => @step, :type => 'Given', :pattern => "string pattern", :line => 3, :column => 5, :file_path => '/path/to/steps', :group_tag => 'basic'}
              end
            end
          end
          
          describe "#includes_step_file?" do
            before(:each) do
              RunnerFile.stub!(:new).and_return(mock('runner file', :step_files_and_names => [{:name => 'basic', :file_path => '/path/to/basic'}]))
            end
            
            it "should return true if the step file name is used by the story" do
              @story_file.includes_step_file?('basic').should be_true
            end
            
            it "should return false if the step file name is not used by the story" do
              @story_file.includes_step_file?('foo').should be_false
            end
          end
          
          describe "#undefined_steps" do
            it "should return a list of steps not defined in the story"
          end
        end
        
      end
    end
  end
end