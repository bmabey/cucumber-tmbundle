require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../../lib/spec/mate/story/files'

module Spec
  module Mate
    module Story
      module Files
      
        describe StepsFile do
          before(:each) do
            @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. .. fixtures]))
            @steps_file = StepsFile.new(File.expand_path(File.join(@fixtures_path, %w[stories steps basic_steps.rb])))
          end
          
          it "should determine the runner file" do
            @steps_file.runner_file_path.should == "#{@fixtures_path}/stories/basic.rb"
          end
          
          it "should determine the story file" do
            @steps_file.story_file_path.should == "#{@fixtures_path}/stories/stories/basic.story"
          end
          
          it "should determine the correct alternate file" do
            @steps_file.alternate_file_path.should == @steps_file.story_file_path
          end
          
          describe "#name" do
            it "should return the simple name (based off the file name)" do
              @steps_file.name.should == 'basic'
            end
          end
          
          describe "#new_steps_line_number" do
            describe "when the steps_for line is at the top" do
              it "should return the next line" do
                @steps_file.new_steps_line_number.should == 2
              end
            end
            
            describe "when the steps_for line is not at the top" do
              before(:each) do
                @steps_file = StepsFile.new(File.expand_path(File.join(@fixtures_path, %w[stories steps additional_basic_steps.rb])))
              end
              
              it "should return the line after steps_for" do
                @steps_file.new_steps_line_number.should == 7
              end
            end
          end
          
          describe "#alternate_files_and_names" do
            before(:each) do
              @basic_runner_file = mock('basic runner file', :step_files_and_names => [{:name => 'basic steps', :file_path => "#{@fixtures_path}/stories/stories/basic.story"}])
              RunnerFile.stub!(:new).and_return(@basic_runner_file)
            end
            
            it "should create RunnerFile objects for each non-step ruby file found in the filesystem" do
              # expect
              RunnerFile.should_receive(:new).at_least(:once).with(/\/stories\/.*\.rb$/).and_return(@basic_runner_file)
              
              # when
              @steps_file.alternate_files_and_names
            end
            
            it "should generate a list of story files (and names) which use this steps file" do
              @steps_file.alternate_files_and_names.should ==
                [
                  {:name=>"foo story", :file_path=>"#{@fixtures_path}/stories/feature1/stories/foo.story"},
                  {:name=>"additional basic story", :file_path=>"#{@fixtures_path}/stories/stories/additional_basic.story"},
                  {:name=>"basic story", :file_path=>"#{@fixtures_path}/stories/stories/basic.story"},
                  {:name=>"non standard story", :file_path=>"#{@fixtures_path}/stories/stories/non_standard.story"}
                ]
            end
          end
          
          describe "#step_definitions" do
            before(:each) do
              Spec::Story::Step.stub!(:new).and_return(@step = mock('step'))
            end
            
            it "should return a list of step definitions included in this file" do
              @steps_file.step_definitions.should ==
                [
                  {:step => @step, :type => 'Given', :pattern => "Basic step (given)", :line => 3, :column => 5, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                  {:step => @step, :type => 'Given', :pattern => "another basic step", :line => 7, :column => 5, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                  {:step => @step, :type => 'Given', :pattern => %r{Basic regexp \(given\)}, :line => 11, :column => 5, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                  {:step => @step, :type => 'When', :pattern => "Basic when", :line => 15, :column => 5, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                  {:step => @step, :type => 'Then', :pattern => "Basic then", :line => 19, :column => 5, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                ]
            end
          end
        end
        
      end
    end
  end
end