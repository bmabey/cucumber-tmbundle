require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/cucumber/mate/table_aligner'

module Cucumber
  module Mate
    describe TableAligner do
      it "should align a simple table" do
        unaligned = "   |    a |b|\n|c|  d   |"
        TableAligner.new.align(unaligned).should == "   | a | b |\n   | c | d |"
      end
    end
  end
end