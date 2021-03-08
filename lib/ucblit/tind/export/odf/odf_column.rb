require 'rodf'

module UCBLIT
  module TIND
    module Export
      module ODF
        class ODFColumn < RODF::Column

          attr_reader :elem_attrs

          def initialize(opts = {})
            super

            default_cell_style_name = opts[:default_cell_style_name]
            elem_attrs['table:default-cell-style-name'] = default_cell_style_name if default_cell_style_name

            number_columns_repeated = opts[:number_columns_repeated]
            elem_attrs['table:number-columns-repeated'] = number_columns_repeated if number_columns_repeated
          end

          class << self
            def create(column_style, default_cell_style, num_repeated)
              opts = { style: column_style, default_cell_style_name: default_cell_style }
              opts[:number_columns_repeated] = num_repeated if num_repeated > 1
              ODFColumn.new(opts)
            end
          end

        end
      end
    end
  end
end
