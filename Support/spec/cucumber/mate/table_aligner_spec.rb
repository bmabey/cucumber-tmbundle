require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/cucumber/mate/table_aligner'

module Cucumber
  module Mate
    describe TableAligner do
      it "should align a simple table" do
        unaligned = "  |    a |b|\n" +
                    " |c|  d   |"

        expected = "  | a | b |\n" +
                   "  | c | d |"

        TableAligner.new.align(unaligned).should == expected
      end

      it "should align multiple tables" do
        unaligned = "  |    a |b|\n" +
                    " |c|  d   |\n" +
                    "\n" +
                    "   |x  | y|zz|\n" +
                    " |1|2|3|"

        expected = "  | a | b |\n" +
                   "  | c | d |\n" +
                   "\n" +
                   "   | x | y | zz |\n" +
                   "   | 1 | 2 | 3  |"

        TableAligner.new.align(unaligned).should == expected
      end

      it "should align a table with multi-byte UTF8 values" do
        unaligned = "   | a |b|\n" +
                    "   |÷|  d  |"
        TableAligner.new.align(unaligned).should == "   | a | b |\n" +
                                                    "   | ÷ | d |"
      end
    end
  end
end