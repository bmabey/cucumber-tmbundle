require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/spec/mate/story/text_mate_formatter'

module Spec
  module Mate
    module Story
      describe TextMateFormatter do
        before :each do
          @out = StringIO.new
          @options = mock('options')
          @reporter = TextMateFormatter.new(@options, @out)
        end
        
        it "should just be poked at" do
          @reporter.run_started(1)
          @reporter.story_started('story_title', 'narrative')

          @reporter.scenario_started('story_title', 'succeeded_scenario_name')
          @reporter.step_succeeded('given', 'succeded_step', 'one', 'two')
          @reporter.scenario_succeeded('story_title', 'succeeded_scenario_name')

          @reporter.scenario_started('story_title', 'pending_scenario_name')
          @reporter.step_pending('when', 'pending_step', 'un', 'deux')
          @reporter.scenario_pending('story_title', 'pending_scenario_name', 'not done')

          @reporter.scenario_started('story_title', 'failed_scenario_name')
          @reporter.step_failed('then', 'failed_step', 'en', 'to')
          @reporter.scenario_failed('story_title', 'failed_scenario_name', mock('exception',:backtrace => ["1..","2..."], :message => "FAIL"))
          
          @reporter.scenario_started('story_title', 'scenario_with_given_scenario_name')
          @reporter.found_scenario('given scenario', 'succeeded_scenario_name')
          
          @reporter.story_ended('story_title', 'narrative')
          @reporter.run_ended
        end
        
        it "should create spans for params" do
          @reporter.step_succeeded('given', 'a $coloured $animal', 'brown', 'dog')
          @out.string.should == "                <li class=\"passed\">Given a <span class=\"param\">brown</span> <span class=\"param\">dog</span></li>\n"
        end
        
        it 'should create spanes for params in regexp steps' do
          @reporter.step_succeeded :given, /a (pink|blue) (.*)/, 'brown', 'dog'
          @out.string.should == "                <li class=\"passed\">Given a <span class=\"param\">brown</span> <span class=\"param\">dog</span></li>\n"
        end
        
      end
    end
  end
end