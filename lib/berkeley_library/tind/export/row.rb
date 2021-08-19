module BerkeleyLibrary
  module TIND
    module Export
      class Row

        attr_reader :columns
        attr_reader :row_index

        def initialize(columns, row_index)
          @columns = columns
          @row_index = row_index
        end

        def values
          columns.map { |c| c.value_at(row_index) }
        end

        def each_value(&block)
          columns.map { |c| c.value_at(row_index) }.each(&block)
        end
      end
    end
  end
end
