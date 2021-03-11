require 'ucblit/util/arrays'
require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/table/repeatable'
require 'ucblit/util/ods/xml/table/table_cell'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          class TableRow < Repeatable

            # ------------------------------------------------------------
            # Accessors

            attr_reader :row_style

            # ------------------------------------------------------------
            # Initializer

            # @param table [Table] the table
            def initialize(row_style, number_repeated = 1, table:)
              super('table-row', 'number-rows-repeated', number_repeated, table: table)
              @row_style = row_style

              set_default_attributes!
            end

            # ------------------------------------------------------------
            # Public utility methods

            def set_value_at(column_index, value = nil, cell_style = nil)
              explicit_cells[column_index] = TableCell.new(value, cell_style, table: table)
            end

            def get_value_at(column_index)
              (cell = explicit_cells[column_index]) && cell.value
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
              return cell.tap { |c| explicit_cells << c } if (explicit_cell_count + 1) <= table.column_count

              raise ArgumentError, "Can't add cell #{explicit_cell_count} to table with only #{table.column_count} columns"
            end

            # ----------------------------------------
            # Protected XML::ElementNode overrides

            def children
              [].tap do |cc|
                each_cell { |c| cc << c }
                cc.concat(other_children)
              end
            end

            # ------------------------------------------------------------
            # Private methods

            private

            def column_count_actual
              [table.column_count, Table::MIN_COLUMNS].max
            end

            def explicit_cells
              @explicit_cells ||= []
            end

            def set_default_attributes!
              set_attribute('style-name', row_style.style_name)
            end

            def other_children
              @other_children ||= []
            end

            def explicit_cell_count
              explicit_cells.size
            end

            def each_cell(columns_yielded = 0, remaining = explicit_cells, &block)
              columns_yielded, remaining = yield_while_non_nil(columns_yielded, remaining, &block)
              columns_yielded, remaining = yield_while_nil(columns_yielded, remaining, &block)
              each_cell(columns_yielded, remaining, &block) unless remaining.empty?
            end

            def yield_while_non_nil(columns_yielded, remaining, &block)
              non_nil_cells = remaining.take_while { |c| !c.nil? }
              non_nil_cells.each(&block)
              non_nil_cell_count = non_nil_cells.size

              [columns_yielded + non_nil_cell_count, remaining[non_nil_cell_count..]]
            end

            def yield_while_nil(columns_yielded, remaining, &block)
              nil_cell_count = Arrays.count_while(values: remaining, &:nil?)
              remaining = remaining[nil_cell_count..]

              empty_required = remaining.empty? ? (column_count_actual - columns_yielded) : nil_cell_count
              yield_repeat_empty(empty_required, &block)
              columns_yielded += empty_required

              [columns_yielded, remaining]
            end

            def yield_repeat_empty(num_repeats, &block)
              empty_cell = TableCell.repeat_empty(num_repeats, table: table)
              block.call(empty_cell)
            end

          end
        end
      end
    end
  end
end
