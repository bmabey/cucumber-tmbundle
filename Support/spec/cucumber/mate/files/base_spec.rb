require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/cucumber/mate/files'

module Cucumber
  module Mate
    
    module Files
    
      describe Base do
        before(:each) do
          @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. fixtures]))
          @file = Base.new(File.expand_path(File.join(@fixtures_path, %w[features basic.feature])))
        end
        
        it "should determine the base project path" do
          @file.project_root.should == @fixtures_path
        end
        
        it "should determine the relative path (relative to the project_root)" do
          @file.relative_path.should == 'features/basic.feature'
        end
        
        it "should determine the name of the file" do
          @file.name.should == 'basic'
        end
        
        describe "#create_from_file_path" do
          describe "when file name is not valid step nor feature file name" do
            it "should throw a descriptive exception" do
              lambda { Base.create_from_file_path("/path/to/some_feature.features") }.should raise_error(InvalidFilePathError)
            end
          end
          describe "when file name is .feature" do
            before(:each) do
              @file = Base.create_from_file_path("/path/to/some_feature.feature")
            end
            it do
              @file.class.should == FeatureFile
            end
          end
          describe "when file name is _steps.rb" do
            before(:each) do
              @file = Base.create_from_file_path("/path/to/some_steps.rb")
            end
            it do
              @file.class.should == StepsFile
            end
          end
        end
        
        describe "#default_file_path" do
          describe "when the file type is invalid" do
            it "should throw a descriptive exception" do
              lambda { @file.default_file_path(:blah) }.should raise_error(ArgumentError)
            end
          end
          
          it "should determine the default steps file path" do
            @file.default_file_path(:steps).should == "#{@fixtures_path}/features/step_definitions/basic_steps.rb"
          end
          
          it "should determine the default feature file path" do
            @file.default_file_path(:feature).should == "#{@fixtures_path}/features/basic.feature"
          end
        end
        
        describe "#file_path" do
          describe "when the file type is invalid" do
            it "should throw a descriptive exception" do
              lambda { @file.file_path(:blah) }.should raise_error(ArgumentError)
            end
          end
          
          describe "when looking for an existing steps file" do
            describe "when the file is the standard location" do
              it "should return the path to the existing file" do
                @file.file_path(:steps).should == "#{@fixtures_path}/features/step_definitions/basic_steps.rb"
              end
            end
            
            describe "when the file is in a non-standard location" do
              before(:each) do
                @file = Base.new(File.expand_path(File.join(@fixtures_path, %w[features non_standard.feature])))
              end
              
              it "should return the path to the existing file" do
                @file.file_path(:steps).should == "#{@fixtures_path}/features/non_standard_dir/step_definitions/non_standard_steps.rb"
              end
            end
          end
                    
          
          describe "when looking for an existing feature file" do
            describe "when the file is the standard location" do
              it "should return the path to the existing file" do
                @file.file_path(:feature).should == "#{@fixtures_path}/features/basic.feature"
              end
            end
            
            describe "when the file is in a non-standard location" do
              before(:each) do
                @file = Base.new(File.expand_path(File.join(@fixtures_path, %w[features non_standard_dir runners non_standard.rb])))
              end
              
              it "should return the path to the existing file" do
                @file.file_path(:feature).should == "#{@fixtures_path}/features/non_standard.feature"
              end
            end
          end
          
          describe "when looking for all existing files" do
            it "should find all feature files" do
              expected = %w[additional_basic.feature basic.feature feature1/foo.feature non_standard.feature]
              expected.map! { |path| FeatureFile.new(File.join(project_root, "features", path)) }
              @file.all(:feature).should == expected
            end

            it "should find all steps files" do
              expected = %w[feature1/step_definitions/foo_steps.rb
                non_standard_dir/step_definitions/non_standard_steps.rb
                step_definitions/additional_basic_steps.rb
                step_definitions/basic_steps.rb
                step_definitions/global_steps.rb
                step_definitions/unconventional_steps.rb
                ]
              expected.map! { |path| StepsFile.new(File.join(project_root, "features", path)) }
              @file.all(:steps).should == expected
            end
          end

          
          
        end # file_path
        
      end
      
    end
  end
end