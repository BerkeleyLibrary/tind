module BerkeleyLibrary
  module TIND
    module Export
      class RowMetrics
        attr_reader :formatted_row_height

        def initialize(formatted_row_height, wrap_columns)
          @formatted_row_height = formatted_row_height
          @wrap_columns = wrap_columns
        end

        def wrap?(col_index)
          @wrap_columns.include?(col_index)
        end
      end
    end
  end
end
