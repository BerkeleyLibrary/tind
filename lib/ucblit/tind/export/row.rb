module UCBLIT
  module TIND
    module Export
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

        def each_value(&block)
          columns.map { |c| c.value_at(row) }.each(&block)
        end
      end
    end
  end
end
