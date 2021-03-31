require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/loext/table_protection'
require 'ucblit/util/ods/xml/style/column_style'
require 'ucblit/util/ods/xml/table/table_column'
require 'ucblit/util/ods/xml/table/table_row'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          class Table < XML::ElementNode
            # ------------------------------------------------------------
            # Constants

            MIN_COLUMNS = 1024
            MIN_ROWS = 1_048_576

            # ------------------------------------------------------------
            # Accessors

            attr_reader :table_name

            attr_reader :table_style

            # @return [XML::Office::AutomaticStyles] the document styles
            attr_reader :styles

            # ------------------------------------------------------------
            # Initializers

            # Initializes a new table
            #
            # @param name [String] the table name
            # @param style [XML::Style::TableStyle] the table style, if other than default
            # @param styles [XML::Office::AutomaticStyles] the document styles
            # @param protected [Boolean] whether the table is protected
            def initialize(table_name, table_style = nil, styles:, protected: true)
              super(:table, 'table', doc: styles.doc)

              @table_name = table_name
              @table_style = table_style || styles.default_style(:table)
              @styles = styles

              set_attribute('name', self.table_name)
              set_attribute('style-name', self.table_style.style_name)

              protect! if protected
            end

            # ------------------------------------------------------------
            # Accessors and utility methods

            def column_count
              @column_count ||= 0
            end

            def row_count
              @row_count ||= 0
            end

            def get_value_at(row_index, column_index)
              (row = rows[row_index]) && row.get_value_at(column_index)
            end

            def add_column(header, width = nil, protected: false)
              add_column_with_styles(
                header,
                column_style: styles.find_or_create_column_style(width),
                default_cell_style: styles.find_or_create_cell_style(protected)
              )
            end

            def add_column_with_styles(header, column_style:, default_cell_style: nil, header_cell_style: nil)
              cell_style = default_cell_style || styles.find_or_create_cell_style
              add_or_repeat_column(column_style, cell_style).tap do
                header_row = rows[0] || add_row
                header_row.set_value_at(column_count, header, header_cell_style)
                self.column_count += 1
              end
            end

            def add_empty_columns(number_repeated, width = nil, protected: false)
              column_style = styles.find_or_create_column_style(width)
              default_cell_style = styles.find_or_create_cell_style(protected)

              TableColumn.new(column_style, default_cell_style, number_repeated, table: self).tap do |col|
                columns << col
                self.column_count += number_repeated
              end
            end

            # Adds a new row with the specified height.
            # @param height [String] the row height. Defaults to {XML::Style::RowStyle::DEFAULT_HEIGHT}.
            # @param number_repeated [Integer] the number of identical rows to repeat
            # @return [TableRow] the new row
            def add_row(height = nil, number_repeated = 1)
              row_style = styles.find_or_create_row_style(height)
              TableRow.new(row_style, number_repeated, table: self).tap do |row|
                rows << row
                self.row_count += number_repeated
              end
            end

            # ------------------------------------------------------------
            # Public XML::ElementNode overrides

            def add_child(child)
              return child.tap { |column| columns << column } if child.is_a?(TableColumn)
              return child.tap { |row| rows << row } if child.is_a?(TableRow)

              child.tap { |c| other_children << c }
            end

            # ------------------------------------------------------------
            # Protected methods

            protected

            # ----------------------------------------
            # Protected XML::ElementNode overrides

            def children
              [other_children, columns, rows].flatten
            end

            def create_element
              ensure_empty_columns!
              ensure_empty_rows!

              super
            end

            # ------------------------------------------------------------
            # Private methods

            private

            # ------------------------------
            # Private writers

            attr_writer :column_count

            attr_writer :row_count

            # ------------------------------
            # Private readers

            def columns
              @columns ||= []
            end

            def rows
              @rows ||= []
            end

            def other_children
              @other_children ||= []
            end

            # ------------------------------
            # Private utility methods

            def protect!
              set_attribute('protected', 'true')
              add_child(LOExt::TableProtection.new(doc: doc))
            end

            def add_or_repeat_column(column_style, default_cell_style)
              if (last_column = columns.last).nil? || !last_column.has_styles?(column_style, default_cell_style)
                TableColumn.new(column_style, default_cell_style, table: self).tap { |c| columns << c }
              else
                last_column.tap(&:increment_repeats!)
              end
            end

            # TODO: do we really need to use the LibreOffice default width/height?

            def ensure_empty_columns!
              empty_required = MIN_COLUMNS - column_count
              add_empty_columns(empty_required, '0.889in') if empty_required > 0
            end

            def ensure_empty_rows!
              empty_required = MIN_ROWS - row_count
              add_row('0.178in', empty_required) if empty_required > 0
            end
          end
        end
      end
    end
  end
end
