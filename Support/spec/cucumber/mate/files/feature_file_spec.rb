require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/cucumber/mate/files'

module Cucumber
  module Mate
    module Files
    
      describe FeatureFile do
        
        #TODO Get rid of fixtures and create the example files in specs inline (and stub the IO.read call)
        
        def feature_file_from_fixtures(feature_name)
          FeatureFile.new(File.expand_path(File.join(@fixtures_path, "features", "#{feature_name}.feature")))
        end
        
        before(:each) do
          @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. fixtures]))
          @feature_file = feature_file_from_fixtures('basic')
        end
        
        it "should be a feature file" do
          @feature_file.should be_feature_file
        end
        
        # describe "when a steps file exists on the filesystem (even if not using the assumed directory structure)" do
        #   before(:each) do
        #     @feature_file = FeatureFile.new(File.expand_path(File.join(@fixtures_path, %w[features non_standard.feature])))
        #   end
        #   
        #   it "should return the path to the existing steps file" do
        #     @feature_file.steps_file_path.should == "#{@fixtures_path}/features/non_standard_dir/step_definitions/non_standard_steps.rb"
        #   end
        # end
        # 
        # describe "when a steps file doesn't exist on the filesystem" do
        #   it "should determine the path to the new steps file (and assume the proposed directory structure)" do
        #     @feature_file.steps_file_path.should == "#{@fixtures_path}/features/step_definitions/basic_steps.rb"
        #   end
        # end
        
        it "should not be a steps file" do
          @feature_file.should_not be_steps_file
        end
        
        it "should return the correct step file path" do
          @feature_file.alternate_file_path.should == "#{@fixtures_path}/features/step_definitions/basic_steps.rb"
        end
        
        it "should determine the correct alternate file as the step file" do
          @feature_file.alternate_file_path.should == @feature_file.steps_file_path
        end
        
        describe "#name" do
          it "should return the simple name (based off the file name)" do
            @feature_file.name.should == 'basic'
          end
        end
        
        describe "#rake_task" do
          it "should return nil when none is defined in the file" do
            @feature_file.rake_task.should be_nil
          end
          
          it "should return the rake task defined in the features file" do            
            feature_file = feature_file_from_fixtures('non_standard')
            feature_file.rake_task.should == 'some_defined_task_in_feature:file'
          end
        end
        
        describe "#profile" do
          it "should return nil when none is defined in the file" do
            @feature_file.profile.should be_nil
          end
          
          it "should return the rake task defined in the features file" do            
            feature_file = feature_file_from_fixtures('non_standard')
            feature_file.profile.should == 'some_defined_profile_in_feature'
          end
        end
        
        describe "#alternate_files_and_names" do
          before(:each) do
            StepDetector.stub!(:new).and_return(mock('step detector', :step_files_and_names => [{:name => 'foo', :file_path => '/path/to/foo'}]))
          end
          
          it "should return the list of step files being used in the feature" do
            @feature_file.alternate_files_and_names.should == [{:name => 'foo', :file_path => '/path/to/foo'}]
          end
        end
        
        describe "#step_information_for_line" do
          it "should not return anything if the line doesn't contain a valid step" do
            @feature_file.step_information_for_line(5).should == nil
          end
          
          it "should return the step information if the line contains a valid step" do
            @feature_file.step_information_for_line(8).should == {:step_type => 'Given', :step_name => 'Basic step (given)'}
          end
          
          it "should return the correct step type if the step type is 'And'" do
            @feature_file.step_information_for_line(9).should == {:step_type => 'Given', :step_name => 'another basic step'}
          end
        end
        
        describe "#location_of_step" do
          describe "when the step definition exists" do
            before(:each) do
              StepDetector.stub!(:new).and_return(@detector = mock('step detector', :step_files_and_names => [{:name => 'basic', :file_path => '/path/to/basic'}]))
              StepsFile.stub!(:new).and_return(@steps = mock('steps file', :step_definitions => [{:step => @step = mock('step', :matches? => true), :type => 'Given', :pattern => "string pattern", :line => 3, :column => 5, :file_path => '/path/to/steps', :group_tag => 'basic'}]))
            end
            
            it "should return the correct file, line and column" do
              @feature_file.location_of_step({:step_type => 'Given', :step_name => 'string pattern'}).should ==
                {:step => @step, :type => 'Given', :pattern => "string pattern", :line => 3, :column => 5, :file_path => '/path/to/steps', :group_tag => 'basic'}
            end
          end
        end
        
        describe "#steps_starting_with" do
          before(:each) do
            StepDetector.stub!(:new).and_return(@detector = mock('step detector', :step_files_and_names => [{:name => 'basic', :file_path => '/path/to/basic'}]))
            StepsFile.stub!(:new).and_return(@steps = mock('steps file', :step_definitions => [
              {:step => @step = mock('step', :matches? => true), :type => 'Given', :pattern => "matching string", :pattern_text => "matching string", :line => 3, :file_path => '/path/to/steps', :group_tag => 'basic'},
              {:step => @step = mock('step', :matches? => true), :type => 'Given', :pattern => /^matching pattern/, :pattern_text => "matching pattern", :line => 3, :file_path => '/path/to/steps', :group_tag => 'basic'},
              {:step => @step = mock('step', :matches? => true), :type => 'Given', :pattern => "not matching string", :pattern_text => "not matching string", :line => 3, :file_path => '/path/to/steps', :group_tag => 'basic'},
            ]))
          end

          describe "when 1 matching string step definition exists" do
            before(:each) do
              @matching_steps = @feature_file.steps_starting_with('matching s')
            end
            
            it "should return the step definition" do
              @matching_steps.size.should == 1
            end
          end

          describe "when 1 matching regex step definition exists" do
            before(:each) do
              @matching_steps = @feature_file.steps_starting_with('matching p')
            end
            
            it "should return the step definition" do
              @matching_steps.size.should == 1
            end
          end

          describe "when multiple matching step definitions exists" do
            before(:each) do
              @matching_steps = @feature_file.steps_starting_with('match')
            end
            
            it "should return the step definition" do
              @matching_steps.size.should == 2
            end
          end
          
          describe "when no matching step definitions exists" do
            before(:each) do
              @matching_steps = @feature_file.steps_starting_with('xxx')
            end
            
            it "should return the step definition" do
              @matching_steps.size.should == 0
            end
          end
        end
        
        describe "#includes_step_file?" do
          before(:each) do
            StepDetector.stub!(:new).and_return(mock('step detector', :step_files_and_names => [{:name => 'basic steps', :file_path => '/path/to/basic'}]))
          end
          
          it "should return true if the step file name is used by the feature" do
            @feature_file.includes_step_file?('basic').should be_true
          end
          
          it "should return false if the step file name is not used by the feature" do
            @feature_file.includes_step_file?('foo').should be_false
          end
        end      
        
        describe "#undefined_steps" do
          it "should return a unique list of steps not defined in the feature" do
            @feature_file.stub!(:all_steps_in_file).and_return([
              {:step_type => 'Given', :step_name => 'a member named Foo'},
              {:step_type => 'When', :step_name => 'Foo walks into a bar'},
              {:step_type => 'Given', :step_name => 'a member named Foo'}
            ])
                          
            @feature_file.stub!(:location_of_step).and_return(nil)
            @feature_file.undefined_steps.should == ([
              {:step_type => 'Given', :step_name => 'a member named Foo'},
              {:step_type => 'When', :step_name => 'Foo walks into a bar'}
            ])
          end
        end
      end
      
    end

  end
end