module Cucumber
  module Mate
    class TableAligner
      def align(lines)
        group_by_tables(lines).map do |group|
          if(group.is_a? Array)
            align_table(group)
          else
            group
          end
        end.flatten
      end

      private

      def group_by_tables(lines)
        current_table = []
        groups = []

        lines.each do |line|
          if line.match(/\s*\|/)
            current_table << line
          else
            groups << current_table unless current_table.empty?
            groups << line
            current_table = []
          end
        end

        groups << current_table unless current_table.empty?
        groups
      end

      def align_table(table)
        table_data = table.map{|line| split_line(line).map{|cell| cell.strip}}
        max_columns = table_data.inject(0) {|memo, row| memo > row.size ? memo : row.size}
        table_data = table_data.map{|row| row.concat([""] * (max_columns - row.size))}
        max_lengths =  table_data.transpose.map { |col| col.map { |cell| cell.unpack("U*").length }.max }.flatten
        initial_space = table.first.match(/(\s*)|/)[1]

        table_data.map do |line|
          initial_space[0..-2].to_s + \
          line.zip(max_lengths).map { |cell, max_length|
            cell + " " * (max_length - cell.unpack("U*").length)
          }.join(' | ') + ' |'
        end
      end

      def split_line(line)
        cells = line.strip.split("|", -1)

        if(cells.last.strip == "")
          cells.delete_at(cells.size - 1) if line =~ /\|\s*$/
        end

        cells
      end
    end
  end
end

