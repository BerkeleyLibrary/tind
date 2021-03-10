require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/table/repeatable'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          class TableColumn < Repeatable

            attr_reader :column_style
            attr_reader :default_cell_style

            # Initializes a new column
            #
            # @param column_style [XML::Style::ColumnStyle] the column style
            # @param default_cell_style [XML::Style::CellStyle] the default cell style for this column
            def initialize(column_style, default_cell_style, number_repeated = 1, table:)
              super('table-column', 'number-columns-repeated', number_repeated, table: table)
              @column_style = column_style
              @default_cell_style = default_cell_style

              set_default_attributes!
            end

            # rubocop:disable Naming/PredicateName
            def has_styles?(column_style, default_cell_style)
              self.column_style == column_style && self.default_cell_style == default_cell_style
            end
            # rubocop:enable Naming/PredicateName

            private

            def set_default_attributes!
              set_attribute('style-name', column_style.name)
              set_attribute('default-cell-style-name', default_cell_style.name)
            end
          end
        end
      end
    end
  end
end
