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
        
        describe "steps_file_path" do
          it "should call file_path" do
            # expects
            @file.should_receive(:file_path).with(:steps)
            # when
            @file.steps_file_path
          end
        end
        
        describe "#default_file_path" do
          describe "when the file type is invalid" do
            it "should throw a descriptive exception" do
              lambda { @file.default_file_path(:blah) }.should raise_error(ArgumentError)
            end
          end
          
          it "should determine the default steps file path" do
            @file.default_file_path(:steps).should == "#{@fixtures_path}/features/steps/basic_steps.rb"
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
          
          describe "when the file doesn't exist" do
            before(:each) do
              @file = Base.new(File.expand_path(File.join(@fixtures_path, %w[features brand_new.feature])))
            end
            
            it "should use the default file path" do
              @file.file_path(:runner).should == @file.default_file_path(:runner)
            end
          end
          
          describe "when looking for an existing steps file" do
            describe "when the file is the standard location" do
              it "should return the path to the existing file" do
                @file.file_path(:steps).should == "#{@fixtures_path}/features/steps/basic_steps.rb"
              end
            end
            
            describe "when the file is in a non-standard location" do
              before(:each) do
                @file = Base.new(File.expand_path(File.join(@fixtures_path, %w[features non_standard.feature])))
              end
              
              it "should return the path to the existing file" do
                @file.file_path(:steps).should == "#{@fixtures_path}/features/non_standard_dir/steps/non_standard_steps.rb"
              end
            end
          end
          
          describe "when looking for an existing runner file" do
            describe "when the file is the standard location" do
              it "should return the path to the existing file" do
                @file.file_path(:runner).should == "#{@fixtures_path}/features/basic.rb"
              end
            end
            
            describe "when the file is in a non-standard location" do
              before(:each) do
                @file = Base.new(File.expand_path(File.join(@fixtures_path, %w[features non_standard.feature])))
              end
              
              it "should return the path to the existing file" do
                @file.file_path(:runner).should == "#{@fixtures_path}/features/non_standard_dir/runners/non_standard.rb"
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
          
        end # file_path
        
        describe "#file_paths" do
          it "should description" do
            
          end
        end
      end
      
    end
  end
end