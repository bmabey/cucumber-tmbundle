require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/cucumber/mate/files'

module Cucumber
  module Mate
    module Files
    
      describe StepsFile do
        before(:each) do
          @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. fixtures]))
          @steps_file = StepsFile.new(File.expand_path(File.join(@fixtures_path, %w[features step_definitions basic_steps.rb])))
        end        
        
        it "should determine the feature file" do          
          @steps_file.feature_file_path.should == "#{@fixtures_path}/features/basic.feature"
        end
        
        it "should determine the correct alternate file" do
          @steps_file.alternate_file_path.should == @steps_file.feature_file_path
        end
        
        describe "#name" do
          it "should return the simple name (based off the file name)" do
            @steps_file.name.should == 'basic'
          end
        end
        
        describe "#rake_task" do
          it "should delegate to the file's feature file" do
            FeatureFile.should_receive(:new).with(@steps_file.feature_file_path).and_return(feature_file = mock('feature file'))
            feature_file.stub!(:rake_task).and_return("some_rake_task")
            
            @steps_file.rake_task.should == "some_rake_task"
          end
        end
        
        describe "#profile" do
          it "should delegate to the file's feature file" do
            FeatureFile.should_receive(:new).with(@steps_file.feature_file_path).and_return(feature_file = mock('feature file'))
            feature_file.stub!(:profile).and_return("watir")
            
            @steps_file.profile.should == "watir"
          end
        end
        
        describe "#alternate_files_and_names" do
          it "should generate a list of feature files (and names) which use this steps file" do
            pending
            @steps_file.alternate_files_and_names.should ==
              [
                {:name=>"foo feature", :file_path=>"#{@fixtures_path}/features/feature1/features/foo.feature"},
                {:name=>"additional basic feature", :file_path=>"#{@fixtures_path}/features/additional_basic.feature"},
                {:name=>"basic feature", :file_path=>"#{@fixtures_path}/features/basic.feature"},
                {:name=>"non standard feature", :file_path=>"#{@fixtures_path}/features/non_standard.feature"}
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
                {:step => @step, :type => 'Given', :pattern => "Basic step (given)", :pattern_text => "Basic step (given)", :line => 5, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                {:step => @step, :type => 'Given', :pattern => "another basic step", :pattern_text => "another basic step", :line => 9, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                {:step => @step, :type => 'Given', :pattern => %r{Basic regexp (.*)}, :pattern_text => "Basic regexp (.*)", :line => 13, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                {:step => @step, :type => 'Given', :pattern => /classic regexp/, :pattern_text => "classic regexp", :line => 17, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                {:step => @step, :type => 'When', :pattern => "Basic when", :pattern_text => "Basic when", :line => 21, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
                {:step => @step, :type => 'Then', :pattern => "Basic then", :pattern_text => "Basic then", :line => 25, :file_path => @steps_file.full_file_path, :group_tag => 'basic'},
              ]
          end
        end
      end
      
    end

  end
end