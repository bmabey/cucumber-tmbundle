module Cucumber
  module Mate
    class TableAligner
      def align(table_text)
        table_text =~ /^(\s*)\|.*$/
        initial_space = $1 

        table_data = table_text.split(/\n/).map do |line|
          just_cells = line.strip  
          just_cells.split('|').map{|cell| cell.strip }
        end

        max_lengths = table_data.transpose.map { |col| col.map { |cell| cell.unpack("U*").length }.max }.flatten

        table_data.map do |line|
          initial_space[0..-2].to_s + \
          line.zip(max_lengths).map { |cell, max_length|
            "%-#{ max_length }s" % cell
          } .join(' | ') + ' |'
        end.join("\n")
      end
    end
  end
end

