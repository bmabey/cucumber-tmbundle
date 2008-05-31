require File.dirname(__FILE__) + '/../../../lib/spec/mate/choose_step_file_command'

module Spec
  module Mate
    describe ChooseStepFileCommand do
      before(:each) do
        @c = ChooseStepFileCommand.new
      end
      
      def full_path(rel_path)
        path = File.dirname(__FILE__) + '/../../../fixtures/stories/' + rel_path
        File.expand_path(path)
      end
      
      it 'should determine story files' do
        @c.file_type('/a/full/path/stories/stories/foo.story').should == 'story'
      end
      
      it 'should determine step files' do
        @c.file_type('/a/full/path/stories/steps/foo_steps.rb').should == 'steps file'
      end
      
      it 'should determine story runner files' do
        @c.file_type('/a/full/path/stories/foo.rb').should == 'runner file'
      end
      
      it 'should determine story runner files (in sub-directories)' do
        @c.file_type('/a/full/path/stories/feature1/foo.rb').should == 'runner file'
      end
      
      it "should determine correct story runner file from story" do
        @c.story_runner_file_for('/a/full/path/stories/stories/foo.story').should == 
                                '/a/full/path/stories/steps/foo_steps.rb'
      end
      
      it "should determine correct story runner file from story (in sub-directory)" do
        @c.story_runner_file_for('/a/full/path/stories/feature1/stories/foo.story').should == 
                                '/a/full/path/stories/feature1/steps/foo_steps.rb'
      end
      
      it "should parse steps from a runner file" do
        file_content = <<-RUNNER
require File.join(File.dirname(__FILE__).gsub(/stories(.*)/,"stories"),"helper")

with_steps_for :foo, :bar, :baz do
  run_story(File.expand_path(__FILE__))
end
RUNNER
        @c.parse_steps(file_content).should == %w( foo bar baz )
      end
      
      it "should find full path of step file based off of name only" do
        @c.full_path_for_step_name('basic').should == full_path('steps/basic_steps.rb')
      end
      
      describe "when in a story file" do
        it "should parse corresponding runner file's included steps" do
          @c.step_files_for(File.dirname(__FILE__) + '/../../../fixtures/stories/stories/basic.story').should == [
                                      {:name => 'basic',  :path => full_path('steps/basic_steps.rb')},
                                      {:name => 'global', :path => full_path('steps/global_steps.rb')}]
        end
        
        it "should parse corresponding runner file's included steps (when in sub-dir)" do
          @c.step_files_for(File.dirname(__FILE__) + '/../../../fixtures/stories/feature1/stories/foo.story').should == [
                                      {:name => 'foo',    :path => full_path('feature1/steps/foo_steps.rb')},
                                      {:name => 'global', :path => full_path('steps/global_steps.rb')}]
        end
      end
      
      # it 'should determine story files' do
      #   '/a/full/path/stories/stories/foo.story'.should be_a('story')
      # end
      # 
      # it 'should determine step files' do
      #   '/a/full/path/stories/steps/foo_steps.rb'.should be_a('steps file')
      # end
      # 
      # it 'should determine story runner files' do
      #   '/a/full/path/stories/foo.rb'.should be_a('runner file')
      # end
      # 
      # it 'should determine story runner files (in sub-directories)' do
      #   '/a/full/path/stories/feature1/foo.rb'.should be_a('runner file')
      # end
      
      # describe 'when in a story file' do
      #   
      #   
      #   it 'should locate the related story runner file' do
      #     @c.story_runner_file_for('/a/full/path/stories/stories/foo.story').should == 
      #                               '/a/full/path/stories/steps/foo_steps.rb'
      #   end
      #   
      #   
      # end
    end
    
#     class Twin
#       def initialize(expected)
#         @expected = expected
#       end
# 
#       def matches?(actual)
#         @actual = actual
#         # Satisfy expectation here. Return false or raise an error if it's not met.
#         command = SwitchCommand.new
# 
#         path = command.twin(@actual)
#         path.should == @expected
# 
#         path = command.twin(@expected)
#         path.should == @actual
#         true
#       end
# 
#       def failure_message
#         "expected #{@actual.inspect} to twin #{@expected.inspect}, but it didn't"
#       end
# 
#       def negative_failure_message
#         "expected #{@actual.inspect} not to twin #{@expected.inspect}, but it did"
#       end
#       
#       def description
#         "twin #{@actual} <=> #{@expected}"
#       end
#     end
#     
#     class BeA
#       def initialize(expected)
#         @expected = expected
#       end
# 
#       def matches?(actual)
#         @actual = actual
#         c = SwitchCommand.new
#         c.file_type(@actual).should == @expected
#         true
#       end
# 
#       def failure_message
#         "expected #{@actual.inspect} to be_a #{@expected.inspect}, but it didn't"
#       end
# 
#       def negative_failure_message
#         "expected #{@actual.inspect} not to be_a #{@expected.inspect}, but it did"
#       end
#     end
# 
#     def be_a(expected)
#       BeA.new(expected)
#     end
# 
#     describe SwitchCommand, "in a regular app" do
#       include Spec::Mate
#       def twin(expected)
#         Twin.new(expected)
#       end
#       
#       it do
#         "/a/full/path/stories/snoopy/stories/mooky.story".should twin(
#         "/a/full/path/stories/snoopy/steps/mooky_steps.rb")
#       end
#       
#       it "should suggest plain story" do
#         "/a/full/path/stories/snoopy/stories/mooky.story".should be_a("story")
#       end
# 
#       it "should suggest plain step file" do
#         "/a/full/path/stories/snoopy/steps/mooky_steps.rb".should be_a("steps file")
#       end
# 
#       it "should create story for story files" do
#         story_file = <<-STORY
# Story: ${1:title}
# 
#   As a ${2:role}
#   I want ${3:feature}
#   So that ${4:value}
# 
#   $0
# STORY
#         SwitchCommand.new.content_for('story', "stories/stories/basic.story").should == story_file
#         SwitchCommand.new.content_for('story', "stories/foo/stories/basic.story").should == story_file
#       end
#       
#       it "should create steps for steps files" do
#         steps_file = <<-STEPS
# steps_for(:${1:steps}) do
#   Given "${2:condition}" do
# 
#   end
# end
# STEPS
#         SwitchCommand.new.content_for('spec', "spec/steps/basic_steps.rb").should == steps_file
#         SwitchCommand.new.content_for('spec', "spec/foo/steps/basic_steps.rb").should == steps_file
#       end
#     end
  end
end
