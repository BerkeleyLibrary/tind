module UCBLIT
  module TIND
    class MARCTable
      class Row

        attr_reader :columns
        attr_reader :row

        def initialize(columns, row)
          @columns = columns
          @row = row
        end

        def values
          columns.map { |c| c.value_at(row) }
        end
      end
    end
  end
end
