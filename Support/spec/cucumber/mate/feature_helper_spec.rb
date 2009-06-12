require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/cucumber/mate/feature_helper'

module Cucumber
  module Mate

    describe FeatureHelper do
      before(:each) do
        @fixtures_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. fixtures]))
        # Default - don't let TextMateHelper actually perform any actions
        TextMateHelper.stub!(:goto_file)
        TextMateHelper.stub!(:display_select_list)
        TextMateHelper.stub!(:request_confirmation)
        TextMateHelper.stub!(:create_and_open_file)
        TextMateHelper.stub!(:insert_text)
        TextMateHelper.stub!(:create_file)

        File.stub!(:file?).and_return(true)

        @helper_file = mock('helper file',
                        :feature_file? => true,
                        :feature_file_path => '/path/to/feature/file',
                        :steps_file_path => '/path/to/step_definitions/file',
                        :runner_file_path => '/path/to/runner/file',
                        :alternate_file_path => "/alternate/file/path",
                        :alternate_files_and_names => [
                            {:name => 'one', :file_path => "/path/to/one"},
                            {:name => 'two', :file_path => "/path/to/two"}
                        ])

        Files::Base.stub!(:create_from_file_path).and_return(@helper_file)
        Files::Base.stub!(:default_content_for).and_return('')
        @feature_helper = FeatureHelper.new("#{@fixtures_path}/features/basic.feature")
      end

      describe "#goto_alternate_file" do
        it "should tell textmate to go to the correct file" do
          # expects
          TextMateHelper.should_receive('goto_file').with('/alternate/file/path', :line => 1, :column => 1)
          # when
          @feature_helper.goto_alternate_file
        end

        describe "when a file doesn't exist" do
          before(:each) do
            File.stub!(:file?).and_return(false)
          end

          it "should ask if the file should be created" do
            # expects
            TextMateHelper.should_receive('request_confirmation')
            # when
            @feature_helper.goto_alternate_file
          end

          describe "and the user chooses to create the file" do
            before(:each) do
              TextMateHelper.stub!(:request_confirmation).and_return(true)
            end

            it "should create the file and add the default contents" do
              # expects
              TextMateHelper.should_receive('create_and_open_file').with('/alternate/file/path')
              TextMateHelper.should_receive('insert_text')
              # when
              @feature_helper.goto_alternate_file
            end
          end

          describe "and the user chooses NOT to create the file" do
            before(:each) do
              TextMateHelper.stub!(:request_confirmation).and_return(false)
            end

            it "should not create the file" do
              # expects
              TextMateHelper.should_not_receive('create_and_open_file')
              # when
              @feature_helper.goto_alternate_file
            end
          end
        end
      end

      describe "#autocomplete_step" do
        describe "with no matches" do
          before(:each) do
            @helper_file.should_receive(:steps_starting_with).with("xxx").and_return([])
            stdout = StringIO.new
            @feature_helper.autocomplete_step(stdout, "  Given xxx")
            stdout.rewind
            @stdout = stdout.read
          end
          it "should print original current_line" do
            @stdout.should == "  Given xxx"
          end
        end

        describe "with 1 match" do
          before(:each) do
            @helper_file.should_receive(:steps_starting_with).with("weird step").
              and_return([{:pattern_text => 'weird step with (\d+) match in step files'}])
            stdout = StringIO.new
            @feature_helper.autocomplete_step(stdout, "  Given weird step")
            stdout.rewind
            @stdout = stdout.read
          end
          it "should print original current_line" do
            @stdout.should == '  Given weird step with ${1:\d+} match in step files'
          end
        end

        describe "with multiple matches and choose 1" do
          before(:each) do
            @helper_file.should_receive(:steps_starting_with).with("weird step").
              and_return([
                {:pattern_text => 'weird step (with|without) object in step (.*)'},
                {:pattern_text => "weird step with second match in step files"}
              ])
            TextMateHelper.should_receive(:display_select_list).with([
              'weird step (with|without) object in step (.*)', 'weird step with second match in step files' ]).
              and_return(0)
            stdout = StringIO.new
            @feature_helper.autocomplete_step(stdout, "  Given weird step")
            stdout.rewind
            @stdout = stdout.read
          end
          it "should print chosen pattern" do
            @stdout.should == '  Given weird step ${1:with|without} object in step ${2:.*}'
          end
        end
      end

      describe "#choose_alternate_file" do
        it "should prompt the user to choose a step file from those included in the runner" do
          # expects
          TextMateHelper.should_receive('display_select_list').with(['one', 'two'])
          # when
          @feature_helper.choose_alternate_file
        end

        it "should tell textmate to open the chosen file (after a user has selected)" do
          TextMateHelper.stub!(:display_select_list).and_return(0)

          # expects
          TextMateHelper.should_receive('goto_file').with("/path/to/one", :line => 1, :column => 1)
          # when
          @feature_helper.choose_alternate_file
        end
      end

      describe "#goto_current_step" do
        describe "when not on a feature file" do
          before(:each) do
            @helper_file.stub!(:feature_file?).and_return(false)
          end

          it "should not tell textmate to do anything" do
            # expects
            TextMateHelper.should_not_receive('display_select_list')
            TextMateHelper.should_not_receive('goto_file')
            # when
            @feature_helper.goto_current_step(1)
          end
        end

        describe "when on a feature file" do
          describe "and the current line doesn't contain a step" do
            before(:each) do
              @helper_file.stub!(:step_information_for_line).and_return(nil)
            end

            it "should not tell textmate to do anything" do
              # expect
              TextMateHelper.should_not_receive('goto_file')
              # when
              @feature_helper.goto_current_step(1)
            end
          end

          describe "and the current line contains a step" do
            before(:each) do
              @helper_file.stub!(:step_information_for_line).and_return({:step_type => 'Given', :step_name => 'blah'})
            end

            describe "when the runner file doesn't exist" do
              before(:each) do
                File.stub!(:file?).and_return(false)
                @helper_file.stub!(:location_of_step)
              end

              it "should prompt to create the runner file" do
                # expects
                TextMateHelper.should_receive('request_confirmation').once # once for the steps file
                # when
                @feature_helper.goto_current_step(1)
              end
            end

            describe "and the step exists" do
              before(:each) do
                @helper_file.stub!(:location_of_step).and_return({:file_path => '/foo/bar', :line => 10, :column => 3})
              end

              it "should tell textmate to goto the file where the step is defined" do
                # expects
                TextMateHelper.should_receive('goto_file').with('/foo/bar', {:line => 10, :column => 3})
                # when
                @feature_helper.goto_current_step(1)
              end
            end

            describe "and the step doesn't exist" do
              before(:each) do
                @helper_file.stub!(:location_of_step).and_return(nil)
                @helper_file.stub!(:step_information_for_line).and_return(nil)
              end

              it "should tell textmate to goto the feature's step file and to insert the step" do
                pending "JohnnyT..."
                # expects
                TextMateHelper.should_receive('goto_file').with('/path/to/step_definitions/file', {:line => 2, :column => 1})
                TextMateHelper.should_receive('insert_text')

                # when
                @feature_helper.goto_current_step(1)
              end
            end
          end
        end # when on a feature file
      end
    end

  end
end
