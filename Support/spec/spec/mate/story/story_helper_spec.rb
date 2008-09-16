require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/spec/mate/story/story_helper'

module Spec
  module Mate
    module Story
      
      describe StoryHelper do
        before(:each) do
          @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. fixtures]))
          # Default - don't let TextMateHelper actually perform any actions
          TextMateHelper.stub!(:goto_file)
          TextMateHelper.stub!(:display_select_list)
          TextMateHelper.stub!(:request_confirmation)
          TextMateHelper.stub!(:create_and_open_file)
          TextMateHelper.stub!(:insert_text)
          TextMateHelper.stub!(:create_file)
          
          File.stub!(:file?).and_return(true)
          
          @helper_file = mock('helper file',
                          :is_story_file? => true,
                          :is_runner_file? => false,
                          :story_file_path => '/path/to/story/file',
                          :steps_file_path => '/path/to/steps/file',
                          :runner_file_path => '/path/to/runner/file',
                          :alternate_file_path => "/alternate/file/path",
                          :alternate_files_and_names => [
                              {:name => 'one', :file_path => "/path/to/one"},
                              {:name => 'two', :file_path => "/path/to/two"}
                          ])
                          
          Files::Base.stub!(:create_from_file_path).and_return(@helper_file)
          Files::Base.stub!(:default_content_for).and_return('')
          @story_helper = StoryHelper.new("#{@fixtures_path}/stories/stories/basic.story")
        end
        
        describe "when a file doesn't exist" do
          before(:each) do
            File.stub!(:file?).and_return(false)
          end
          
          it "should ask if the file should be created" do
            # expects
            TextMateHelper.should_receive('request_confirmation')
            # when
            @story_helper.goto_alternate_file
          end
          
          describe "when the user chooses to create the file" do
            before(:each) do
              TextMateHelper.stub!(:request_confirmation).and_return(true)
            end
            
            it "should create the file and add the default contents" do
              # expects
              TextMateHelper.should_receive('create_and_open_file').with('/alternate/file/path')
              TextMateHelper.should_receive('insert_text')
              # when
              @story_helper.goto_alternate_file
            end
          end
          
          describe "when the user chooses NOT to create the file" do
            before(:each) do
              TextMateHelper.stub!(:request_confirmation).and_return(false)
            end
            
            it "should not create the file" do
              # expects
              TextMateHelper.should_not_receive('create_and_open_file')
              # when
              @story_helper.goto_alternate_file
            end
          end
        end
        
        describe "#goto_alternate_file" do
          describe "when not on a runner file" do
            it "should tell textmate to go to the correct file" do
              # expects
              TextMateHelper.should_receive('goto_file').with('/alternate/file/path', :line => 1, :column => 1)
              # when
              @story_helper.goto_alternate_file
            end
          end
          
          describe "when on a runner file" do
            before(:each) do
              @helper_file.stub!(:is_runner_file?).and_return(true)
            end
            
            it "should prompt the user to choose between the steps and story file" do
              # expects
              TextMateHelper.should_receive('display_select_list').with(['Story File', 'Steps File'])
              # when
              @story_helper.goto_alternate_file
            end
          
            it "should tell textmate to go to the corrent file (after user has chosen)" do
              TextMateHelper.stub!(:display_select_list).and_return(0)
            
              # expects
              TextMateHelper.should_receive('goto_file').with('/path/to/story/file', :line => 1, :column => 1)
              # when
              @story_helper.goto_alternate_file
            end
          
            it "should not tell textmate to go a file (if the user doesn't choose anything)" do
              TextMateHelper.stub!(:display_select_list).and_return(nil)
              
              # expects
              TextMateHelper.should_not_receive('goto_file')
              # when
              @story_helper.goto_alternate_file
            end
          end
        end
        
        describe "#choose_alternate_file" do
          it "should prompt the user to choose a step file from those included in the runner" do
            # expects
            TextMateHelper.should_receive('display_select_list').with(['one', 'two'])
            # when
            @story_helper.choose_alternate_file
          end
          
          it "should tell textmate to open the chosen file (after a user has selected)" do
            TextMateHelper.stub!(:display_select_list).and_return(0)
            
            # expects
            TextMateHelper.should_receive('goto_file').with("/path/to/one", :line => 1, :column => 1)
            # when
            @story_helper.choose_alternate_file
          end
        end
        
        describe "#goto_current_step" do
          describe "when not on a story file" do
            before(:each) do
              @helper_file.stub!(:is_story_file?).and_return(false)
            end
            
            it "should not tell textmate to do anything" do
              # expects
              TextMateHelper.should_not_receive('display_select_list')
              TextMateHelper.should_not_receive('goto_file')
              # when
              @story_helper.goto_current_step(1)
            end
          end
          
          describe "when on a story file" do
            describe "and the current line doesn't contain a step" do
              before(:each) do
                @helper_file.stub!(:step_information_for_line).and_return(nil)
              end
              
              it "should not tell textmate to do anything" do
                # expect
                TextMateHelper.should_not_receive('goto_file')
                # when
                @story_helper.goto_current_step(1)
              end
            end
            
            describe "and the current line contains a step" do
              before(:each) do
                @helper_file.stub!(:step_information_for_line).and_return({:step_type => 'Given', :step_name => 'blah'})
              end
              
              describe "when the runner file doesn't exist" do
                before(:each) do
                  File.stub!(:file?).and_return(false)
                  @helper_file.stub!(:location_of_step)
                end

                it "should prompt to create the runner file" do
                  # expects
                  TextMateHelper.should_receive('request_confirmation').twice # once for the runner file, once for the steps file
                  # when
                  @story_helper.goto_current_step(1)
                end
              end
              
              describe "and the step exists" do
                before(:each) do
                  @helper_file.stub!(:location_of_step).and_return({:file_path => '/foo/bar', :line => 10, :column => 3})
                end
                
                it "should tell textmate to goto the file where the step is defined" do
                  # expects
                  TextMateHelper.should_receive('goto_file').with('/foo/bar', {:line => 10, :column => 3})
                  # when
                  @story_helper.goto_current_step(1)
                end
              end
              
              describe "and the step doesn't exist" do
                before(:each) do
                  @helper_file.stub!(:location_of_step).and_return(nil)
                  @helper_file.stub!(:step_information_for_line).and_return(nil)
                end
                
                it "should tell textmate to goto the story's step file and to insert the step" do
                  pending "JohnnyT..."
                  # expects
                  TextMateHelper.should_receive('goto_file').with('/path/to/steps/file', {:line => 2, :column => 1})
                  TextMateHelper.should_receive('insert_text')
                  
                  # when
                  @story_helper.goto_current_step(1)
                end
              end
            end
          end # when on a story file
        end
      end
      
    end
  end
end