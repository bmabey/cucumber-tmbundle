require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../../lib/spec/mate/story/files'

module Spec
  module Mate
    module Story
      module Files
      
        describe Base do
          before(:each) do
            @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. fixtures]))
            @file = Base.new(File.expand_path(File.join(@fixtures_path, %w[stories stories basic.story])))
          end
          
          it "should determine the base project path" do
            @file.project_root.should == @fixtures_path
          end
          
          it "should determine the relative path (relative to the project_root)" do
            @file.relative_path.should == 'stories/stories/basic.story'
          end
        end
        
      end
    end
  end
end