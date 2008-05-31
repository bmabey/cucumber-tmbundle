require File.dirname(__FILE__) + '/../../spec_helper'
ENV['TM_SUPPORT_PATH'] = '/Applications/TextMate.app/Contents/SharedSupport/Support'

require File.dirname(__FILE__) + '/../../../lib/spec/mate/text_mate_helper'

module Spec
  module Mate
  
    describe TextMateHelper do
      describe ".open_or_prompt" do
        it "should open the file if the file exists" do
          #expects
          TextMate.should_receive(:go_to).with(:file => "#{project_root}/stories/stories/basic.story")
          #when
          TextMateHelper.open_or_prompt("#{project_root}/stories/stories/basic.story")
        end
        
        describe "when the file does not exist" do
          it "should prompt if the file should be created" do
            #expects
            TextMate.should_receive(:request_confirmation)
            #when
            TextMateHelper.open_or_prompt("#{project_root}/stories/stories/new.story")
          end
          
          # it "should create the file if user chooses to" do
          #   TextMate.should_receive(:request_confirmation).and_return(true)
          #   
          #   #expects
          #   File.should_receive(:create)
          #   #when
          #   TextMateHelper.open_or_prompt("#{project_root}/stories/stories/new.story")
          # end
        end
      end
    end

  end
end