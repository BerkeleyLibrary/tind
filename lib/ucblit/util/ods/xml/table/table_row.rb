require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/table/repeatable'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          class TableRow < Repeatable

            attr_reader :row_style

            def initialize(row_style, number_repeated = 1, table:)
              super('table-row', 'number-rows-repeated', number_repeated, table: table)
              @row_style = row_style

              set_default_attributes!
            end

            def set_value_at(column_index, value = nil, cell_style = nil)
              cells[column_index] = TableCell.new(value, cell_style, table: table)
            end

            # ------------------------------------------------------------
            # Public XML::ElementNode overrides

            def add_child(child)
              return add_table_cell(child) if child.is_a?(TableCell)

              child.tap { |c| other_children << c }
            end

            # ------------------------------------------------------------
            # Protected methods

            protected

            # ----------------------------------------
            # Protected utility methods

            def add_table_cell(cell)
              cell.tap { |c| explicit_cells << c }
            end

            # ----------------------------------------
            # Protected XML::ElementNode overrides

            def children
              [].tap do |cc|
                table.column_count.times do |column_index|
                  cell = explicit_cells[column_index]
                  next cc << cell if cell

                  if column_index < 1 || (last_cell = cc.last).nil? || !last_cell.empty?
                    cc << TableCell.new(table: table)
                  else
                    last_cell.increment_repeats!
                  end
                end
                cc.concat(other_children)
              end
            end

            # ------------------------------------------------------------
            # Private methods

            def explicit_cells
              @explicit_cells ||= []
            end

            def set_default_attributes!
              set_attribute('style-name', row_style.name)
            end

            def other_children
              @other_children ||= []
            end

          end
        end
      end
    end
  end
end
