require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/cucumber/mate/runner'

module Cucumber
  module Mate
    describe "a run command", :shared => true do
      it "should run with the cucumber command by default" do
        expect_system_call_to_be_made_with(%r[#{Cucumber::Mate::Runner::CUCUMBER_BIN}])
        when_run_is_called
      end

      it "should run with the cucumber command passed in" do
        expect_system_call_to_be_made_with(%r[/some/path/cucumber ])
        when_run_is_called(nil, "/some/path/cucumber")
      end

      it "should run with /project/path/script/cucumber if present" do
        File.should_receive(:exists?).with("/project/path/script/cucumber").and_return(true)
        expect_system_call_to_be_made_with(%r[/project/path/script/cucumber ])
        when_run_is_called
      end

      it "should run the single feature" do
        expect_system_call_to_be_made_with(/ #{@file.full_file_path}/)
        when_run_is_called
      end

      it "should run with the deafult cucumber options when none are passed in" do
        expect_system_call_to_be_made_with(/--format=html/)
        when_run_is_called
      end

      it "should run with the profile defined in the feature file" do
        # given
        @file.stub!(:profile).and_return('watir')
        expect_system_call_to_be_made_with(/--profile=watir/)
        when_run_is_called
      end

      it "should run with the cucumber options passed in" do
        expect_system_call_to_be_made_with(/--format=custom/)
        when_run_is_called("--format=custom")
      end

      it "should direct the call's output to the passed in output" do
        Kernel.stub!(:system).and_return("features html")
        output = when_run_is_called
        output.string.should =~ /features html/
      end

      it "should output the exact command it is running" do
        Kernel.stub!(:system).and_return("features html")
        output = when_run_is_called
        output.string.should =~ /^Running: .+cucumber /
      end

      describe "when the feature file defines a rake task" do
        before(:each) do
          @file.stub!(:rake_task).and_return('some_task')
        end

        it "should run the feature with the defined rake task" do
          expect_system_call_to_be_made_with(/#{Cucumber::Mate::Runner::RAKE_BIN} #{@file.rake_task} /)
          when_run_is_called
        end

        it "should run the single feature with the rake syntax" do
          expect_system_call_to_be_made_with(/FEATURE=#{@file.full_file_path}/)
          when_run_is_called
        end

        it "should run with the deafult cucumber options when none are passed in with the rake syntax" do
          expect_system_call_to_be_made_with(/CUCUMBER_OPTS="--format=html/)
          when_run_is_called
        end

        it "should run with the cucumber options passed in with the rake syntax" do
          expect_system_call_to_be_made_with(/CUCUMBER_OPTS="--format=custom/)
          when_run_is_called("--format=custom")
        end
      end
    end

    describe Runner do
      before(:each) do
        Files::Base.stub!(:create_from_file_path).and_return(
          @file = mock("feature file", 
            :rake_task => nil, 
            :profile => nil,
            :feature_file_path => 'path_to_feature.feature',
            :relative_path => 'relative_path.feature',
            :full_file_path => '/foo/bar/relative_path.feature'
          )
        )
        Dir.stub!(:chdir).and_yield
        Kernel.stub!(:system)
        File.stub!(:exists?).and_return(false)
      end

      def expect_system_call_to_be_made_with(regex)
        Kernel.should_receive(:system).with(regex)
      end

      it "should create a new Files::Base from the passed in file path" do
        # expect
        Files::Base.should_receive(:create_from_file_path).with("/path/to/file").and_return(stub('file').as_null_object)
        # when
        Runner.new(nil, "/path","/path/to/file")
      end

      describe "#run_feature" do

        def when_run_feature_is_called(cucumber_options=nil, cucumber_bin = nil)
          Runner.new(output=StringIO.new, "/project/path", "/project/path/feature_file", cucumber_bin, cucumber_options).run_feature
          output
        end
        alias :when_run_is_called :when_run_feature_is_called

        it_should_behave_like "a run command"
      end

      describe "#run_scenario" do
        def when_run_scenario_is_called(cucumber_options=nil, cucumber_bin = nil)
          Runner.new(output=StringIO.new, "/project/path", "/project/path/feature_file", cucumber_bin, cucumber_options).run_scenario(12)
          output
        end
        alias :when_run_is_called :when_run_scenario_is_called

        it_should_behave_like "a run command"

        it "should pass the line number in the cucumber options" do
          # given
          runner = Runner.new(output=StringIO.new, "/project/path", @file.full_file_path)

          expect_system_call_to_be_made_with(%r{#{@file.full_file_path}:42 --format=html})

          # when
          runner.run_scenario(42)
        end
      end

      describe "#format_feature" do
        it "should use cucumber's --autoformat on the specified feature file" do
          # given
          runner = Runner.new(output=StringIO.new, "/project/path", "/project/path/feature_file")

          expect_system_call_to_be_made_with(%r{--autoformat \. relative_path.feature$})

          # when
          runner.autoformat_feature
        end
      end
    end
  end
end
