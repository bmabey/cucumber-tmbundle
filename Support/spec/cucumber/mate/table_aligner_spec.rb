require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/cucumber/mate/table_aligner'

module Cucumber
  module Mate
    describe TableAligner do
      it "should align a simple table" do
        unaligned = [
          "  |    a |b|",
          " |c|  d   |"
        ]

        expected = [
          "  | a | b |",
          "  | c | d |"
        ]

        TableAligner.new.align(unaligned).should == expected
      end

      it "should align multiple tables" do
        unaligned = [
          "  |    a |b|",
          " |c|  d   |",
          "",
          "   |x  | y|zz|",
          " |1|2|3|"
        ]

        expected = [
          "  | a | b |",
          "  | c | d |",
          "",
          "   | x | y | zz |",
          "   | 1 | 2 | 3  |"
        ]

        TableAligner.new.align(unaligned).should == expected
      end

      it "should pad short rows out to the longest row" do
        unaligned = [
          "",
          " |a|b|",
          " |x|y|z",
          " |",
          ""
        ]

        expected = [
          "",
          " | a | b |   |",
          " | x | y | z |",
          " |   |   |   |",
          ""
        ]

        TableAligner.new.align(unaligned).should == expected
      end

      it "should align a table with multi-byte UTF8 values" do
        unaligned = [
          "   | aa |b|",
          "   |÷|  d  |"
        ]

        expected = [
          "   | aa | b |",
          "   | ÷  | d |"
        ]

        TableAligner.new.align(unaligned).should == expected
      end

      it "should align a table that has cells with no content" do
        unaligned = [
          "   |a|b|",
          "   |||"
        ]

        expected = [
          "   | a | b |",
          "   |   |   |"
        ]

        TableAligner.new.align(unaligned).should == expected
      end
    end
  end
end