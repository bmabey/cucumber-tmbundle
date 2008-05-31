require File.dirname(__FILE__) + '/../../../lib/spec/mate/switch_command'

module Spec
  module Mate
    class Twin
      def initialize(expected)
        @expected = expected
      end

      def matches?(actual)
        @actual = actual
        # Satisfy expectation here. Return false or raise an error if it's not met.
        command = SwitchCommand.new

        path = command.twin(@actual)
        path.should == @expected

        path = command.twin(@expected)
        path.should == @actual
        true
      end

      def failure_message
        "expected #{@actual.inspect} to twin #{@expected.inspect}, but it didn't"
      end

      def negative_failure_message
        "expected #{@actual.inspect} not to twin #{@expected.inspect}, but it did"
      end
      
      def description
        "twin #{@actual} <=> #{@expected}"
      end
    end
    
    class BeA
      def initialize(expected)
        @expected = expected
      end

      def matches?(actual)
        @actual = actual
        c = SwitchCommand.new
        c.file_type(@actual).should == @expected
        true
      end

      def failure_message
        "expected #{@actual.inspect} to be_a #{@expected.inspect}, but it didn't"
      end

      def negative_failure_message
        "expected #{@actual.inspect} not to be_a #{@expected.inspect}, but it did"
      end
    end

    def be_a(expected)
      BeA.new(expected)
    end

    describe SwitchCommand, "in a regular app" do
      include Spec::Mate
      def twin(expected)
        Twin.new(expected)
      end
      
      it do
        "/a/full/path/stories/snoopy/stories/mooky.story".should twin(
        "/a/full/path/stories/snoopy/steps/mooky_steps.rb")
      end
      
      it "should suggest plain story" do
        "/a/full/path/stories/snoopy/stories/mooky.story".should be_a("story")
      end

      it "should suggest plain step file" do
        "/a/full/path/stories/snoopy/steps/mooky_steps.rb".should be_a("steps file")
      end

      it "should create story for story files" do
        story_file = <<-STORY
Story: ${1:title}

  As a ${2:role}
  I want ${3:feature}
  So that ${4:value}

  $0
STORY
        SwitchCommand.new.content_for('story', "stories/stories/basic.story").should == story_file
        SwitchCommand.new.content_for('story', "stories/foo/stories/basic.story").should == story_file
      end
      
      it "should create steps for steps files" do
        steps_file = <<-STEPS
steps_for(:${1:steps}) do
  Given "${2:condition}" do

  end
end
STEPS
        SwitchCommand.new.content_for('spec', "spec/steps/basic_steps.rb").should == steps_file
        SwitchCommand.new.content_for('spec', "spec/foo/steps/basic_steps.rb").should == steps_file
      end
    end
  end
end
