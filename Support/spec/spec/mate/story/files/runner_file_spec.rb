require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../../lib/spec/mate/story/files'

module Spec
  module Mate
    module Story
      module Files
      
        describe RunnerFile do
          before(:each) do
            @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. .. fixtures]))
            @runner_file = RunnerFile.new(File.expand_path(File.join(@fixtures_path, %w[stories basic.rb])))
          end
          
          it "should determine the story file" do
            @runner_file.story_file_path.should == "#{@fixtures_path}/stories/stories/basic.story"
          end
          
          it "should determine the steps file" do
            @runner_file.steps_file_path.should == "#{@fixtures_path}/stories/steps/basic_steps.rb"
          end
          
          describe "#name" do
            it "should return the simple name (based off the file name)" do
              @runner_file.name.should == 'basic'
            end
          end
          
          describe "#alternate_files_and_names" do
            it "should generate a list of the story file and included steps files" do
              @runner_file.alternate_files_and_names.should ==
                [
                  {:name => 'basic story', :file_path => "#{@fixtures_path}/stories/stories/basic.story"},
                  {:name => 'basic steps', :file_path => "#{@fixtures_path}/stories/steps/basic_steps.rb"},
                  {:name => 'global steps', :file_path => "#{@fixtures_path}/stories/steps/global_steps.rb"}
                ]
            end
          end
          
          describe "#step_files_and_names" do
            describe "when the file path initially passed to initialize is not a runner file" do
              before(:each) do
                @runner_file = RunnerFile.new(File.expand_path(File.join(@fixtures_path, %w[stories helper.rb])))
              end
              
              it "should return a blank array of step files" do
                @runner_file.step_files_and_names.should == []
              end
            end
            
            describe "when this runner file doesn't exist" do
              before(:each) do
                File.stub!(:file?).and_return(false)
              end
              
              it "should generate a list of the default step file" do
                @runner_file.step_files_and_names.should == [{:name => 'basic steps', :file_path => "#{@fixtures_path}/stories/steps/basic_steps.rb"}]
              end
            end
            
            it "should generate a list of all included step files" do
              @runner_file.step_files_and_names.should ==
                [
                  {:name => 'basic steps', :file_path => "#{@fixtures_path}/stories/steps/basic_steps.rb"},
                  {:name => 'global steps', :file_path => "#{@fixtures_path}/stories/steps/global_steps.rb"}
                ]
            end
          end
        end
        
      end
    end
  end
end