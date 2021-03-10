require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/loext/table_protection'
require 'ucblit/util/ods/xml/style/column_style'

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

            attr_reader :name
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
            def initialize(name, table_style = nil, styles:, protected: true)
              super(:table, 'table', doc: styles.doc)

              @name = name
              @styles = styles
              @protected = protected
              @table_style = table_style || styles.default_style(:table)

              set_default_attributes!
              add_default_elements!
            end

            # ------------------------------------------------------------
            # Accessors and utility methods

            def protected?
              @protected
            end

            def column_count
              @column_count ||= 0
            end

            def row_count
              @row_count ||= 0
            end

            def add_column(header, width = nil, protected: false)
              column_style = styles.find_or_create_column_style(width)
              default_cell_style = styles.find_or_create_cell_style(protected)

              add_or_repeat_column(column_style, default_cell_style).tap do
                column_index = column_count - 1
                header_row.set_value_at(column_index, header)
                self.column_count += 1
              end
            end

            def add_empty_columns(number_repeated, width = nil, protected: false)
              column_style = styles.find_or_create_column_style(width)
              default_cell_style = styles.find_or_create_cell_style(protected)

              TableColumn.new(column_style, default_cell_style, number_repeated, table: self).tap do |col|
                cols << col
                self.column_count += number_repeated
              end
            end

            def add_row(height = nil)
              row_style = styles.find_or_create_row_style(height)
              TableRow.new(row_style, table: self).tap do |row|
                rows << row
                self.row_count += 1
              end
            end

            def add_empty_rows(number_repeated, height = nil)
              row_style = styles.find_or_create_row_style(height)
              TableRow.new(row_style, number_repeated, table: self).tap do |row|
                rows << row
                self.row_count += number_repeated
              end
            end

            # ------------------------------------------------------------
            # Public XML::ElementNode overrides

            def add_child(child)
              return add_table_column(child) if child.is_a?(TableColumn)
              return add_table_row(child) if child.is_a?(TableRow)

              child.tap { |c| other_children << c }
            end

            # ------------------------------------------------------------
            # Protected methods

            protected

            # ----------------------------------------
            # Protected utility methods

            def add_table_column(table_column)
              table_column.tap { |column| columns << column }
            end

            def add_table_row(table_row)
              table_row.tap { |row| rows << row }
            end

            # ----------------------------------------
            # Protected XML::ElementNode overrides

            def children
              [].tap do |cc|
                cc.concat(other_children)
                cc.concat(columns)
                cc.concat(rows)
              end
            end

            def create_element
              ensure_empty_columns!
              ensure_empty_rows!

              super
            end

            # ------------------------------------------------------------
            # Private methods

            private

            def ensure_empty_columns!
              empty_required = MIN_COLUMNS - column_count
              add_empty_columns(empty_required) if empty_required > 0
            end

            def ensure_empty_rows!
              empty_required = MIN_ROWS - row_count
              add_empty_rows(empty_required) if empty_required > 0
            end

            def columns
              @columns ||= []
            end

            def rows
              @rows ||= []
            end

            def header_row
              return rows[0] unless rows.empty?

              add_row
            end

            def add_or_repeat_column(column_style, default_cell_style)
              if (last_column = columns.last).nil? ||
                last_column.column_style != column_style ||
                last_column.default_cell_style != default_cell_style

                new_column = TableColumn.new(column_style, default_cell_style, table: self)
                return add_table_column(new_column)
              end

              last_column.tap { |lc| lc.increment_repeats! }
            end

            def set_default_attributes!
              set_attribute('name', name)
              set_attribute('style-name', table_style.name)
              set_attribute('protected', 'true') if protected?
            end

            def add_default_elements!
              children << LOExt::TableProtection.new(doc: doc) if protected?
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
