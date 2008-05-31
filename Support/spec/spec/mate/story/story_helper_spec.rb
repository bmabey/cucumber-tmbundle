require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/spec/mate/story/story_helper'

module Spec
  module Mate
    module Story
      
      describe StoryHelper do
        
        describe "#goto_alternate_file" do
          it "should determine alternate file for a story file" do
            #expect
            ::Spec::Mate::TextMateHelper.should_receive(:open_or_prompt).with("#{project_root}/stories/steps/basic_steps.rb")
            #when
            StoryHelper.new(project_root, "#{project_root}/stories/stories/basic.story").goto_alternate_file
          end

          it "should determine alternate file for a story file (in sub-directory)" do
            #expect
            ::Spec::Mate::TextMateHelper.should_receive(:open_or_prompt).with("#{project_root}/stories/feature1/steps/foo_steps.rb")
            #when
            StoryHelper.new(project_root, "#{project_root}/stories/feature1/stories/foo.story").goto_alternate_file
          end
        end
        
        # describe "#choose_steps_file" do
        #   describe "when in a story file" do
        #     it "should generate a list of steps from the story's runner file" do
        #       
        #       #when
        #       StoryHelper.new(project_root, "#{project_root}/stories/feature1/stories/foo.story").choose_steps_file
        #     end
        #   end
        # end
        
        
        
        describe "#find_step" do
          it "should find a step that exists (when step begins with And)" do
            
            StoryHelper.new(project_root, "#{project_root}/stories/stories/basic.story").find_step('9').should ==
                "#{project_root}/stories/steps/basic_steps.rb:6"
          end
          
          # it "should find a step that exists" do
          #   @sh.find_step(ENV['TM_PROJECT_DIRECTORY'], 'stories/stories/basic.story', '8').should ==
          #       'stories/steps/basic_steps.rb:2'
          # end
        end
        
      end
      
    end
  end
end  
  # describe "#file_type" do
  #   it "should determine story file type (story extension)" do
  #     @sh.file_type("stories/stories/foo.story").should == 'story'
  #   end
  # 
  #   it "should determine story file type (txt extension)" do
  #     @sh.file_type("stories/stories/foo.txt").should == 'story'
  #   end
  # 
  #   it "should determine steps file type" do
  #     @sh.file_type("stories/steps/foo_steps.rb").should == 'steps'
  #   end
  # 
  #   it "should determine story runner file type" do
  #     @sh.file_type("stories/foo.rb").should == 'story_runner'
  #   end
  # end
  # 
  # describe "#alternate_file" do
  #   it "should determine alternate file for a story file" do
  #     @sh.alternate_file('stories/stories/foo.story').should == 'stories/steps/foo_steps.rb'
  #   end
  #       
  #   it "should determine alternate file for a story file (in sub-directory)" do
  #     @sh.alternate_file('stories/feature1/stories/foo.story').should ==
  #                               'stories/feature1/steps/foo_steps.rb'
  #   end
  # end
  # 
  # describe "description" do
  #   it "should description" do
  #     
  #   end
  # end

  # describe "#switch_to_file" do
  #   it "should tell textmate to open the file if it exists" do
  #     @sh.switch
  #   end
  #   
  #   it "should prompt if file should be created if the file doesn't exist" do
  #     
  #   end
  # end