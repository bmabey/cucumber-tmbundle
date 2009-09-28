module Cucumber
  module Mate
    class TableAligner
      def align(table_text)
        align_all(table_text.split("\n")).join("\n")
      end

      private

      def align_all(lines)
        group_by_tables(lines).map do |group|
          if(group.is_a? Array)
            align_table(group)
          else
            group
          end
        end
      end

      def group_by_tables(lines)
        current_table = []
        grouped = []

        lines.each do |line|
          if line.match(/\s*\|/)
            current_table << line
          else
            grouped << current_table unless current_table.empty?
            grouped << line
            current_table = []
          end
        end

        grouped << current_table unless current_table.empty?
        grouped
      end

      def align_table(table)
        table_data = table.map{|line| line.strip.split('|').map{|cell| cell.strip}}
        max_lengths =  table_data.transpose.map { |col| col.map { |cell| cell.unpack("U*").length }.max }.flatten
        initial_space = table.first.match(/(\s*)|/)[1]

        table_data.map do |line|
          initial_space[0..-2].to_s + \
          line.zip(max_lengths).map { |cell, max_length|
            "%-#{ max_length }s" % cell
          }.join(' | ') + ' |'
        end
      end
    end
  end
end

