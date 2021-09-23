require 'berkeley_library/logging'
require 'berkeley_library/tind/export/row_metrics'
require 'berkeley_library/tind/export/config'

module BerkeleyLibrary
  module TIND
    module Export
      class TableMetrics
        include BerkeleyLibrary::Logging
        include Config

        # @return [Table] the table
        attr_reader :table

        # Initializes a new set of metrics for the specified table.
        #
        # @param table [Table] the table
        def initialize(table)
          @table = table
        end

        def formatted_width(col_index)
          inches_numeric = numeric_column_width(col_index)
          format_inches(inches_numeric)
        end

        def row_metrics_for(row_index)
          @metrics_by_row ||= []
          @metrics_by_row[row_index] ||= calc_row_metrics(row_index)
        end

        # ------------------------------------------------------------
        # Private methods

        private

        # ------------------------------
        # Private accessors

        def inch_format
          @inch_format ||= "%0.#{format_digits}fin"
        end

        def numeric_column_width(col_index)
          @numeric_column_widths ||= []
          @numeric_column_widths[col_index] ||= calc_max_width(col_index)
        end

        def cell_widths_for_column(col_index)
          @cell_widths_by_column ||= []
          @cell_widths_by_column[col_index] ||= calc_cell_widths(col_index)
        end

        # ------------------------------
        # Private utility methods

        def calc_max_width(col_index)
          header = table.columns[col_index].header
          w_header = ColumnWidthCalculator.width_inches(header)
          w_cell_max = cell_widths_for_column(col_index).max
          w_max_actual = [w_header, w_cell_max].max
          w_max_rounded = (w_max_actual / w_incr_in).ceil * w_incr_in
          [w_max_rounded, max_col_width_in].min
        end

        def calc_cell_widths(col_index)
          column = table.columns[col_index]
          column.each_value.map { |v| ColumnWidthCalculator.width_inches(v) }
        end

        def format_inches(inches_numeric)
          format(inch_format, inches_numeric)
        end

        def calc_row_metrics(row_index)
          columns_to_wrap = Set.new
          max_wrapped_lines = 1

          table.column_count.times do |col_index|
            wrapped_lines = wrapped_lines_for_cell(row_index, col_index)
            max_wrapped_lines = [wrapped_lines, max_wrapped_lines].max
            columns_to_wrap << col_index if wrapped_lines > 1
          end

          formatted_height = format_row_height(max_wrapped_lines)
          RowMetrics.new(formatted_height, columns_to_wrap)
        end

        # TODO: something smarter, maybe guess at break locations?
        def wrapped_lines_for_cell(row_index, col_index)
          w_col = numeric_column_width(col_index)
          w_cell = numeric_cell_width(row_index, col_index)
          (w_cell / w_col).ceil
        end

        def numeric_cell_width(row_index, col_index)
          cell_widths_by_row = cell_widths_for_column(col_index)
          cell_widths_by_row[row_index] || 0
        end

        def numeric_line_height_inches
          @numeric_line_height_inches ||= begin
            h_exact_pts = font_size_pt * line_height_em
            h_rounded_pts = (h_exact_pts / h_incr_pt).ceil * h_incr_pt
            h_rounded_pts / 72.0
          end
        end

        def format_row_height(lines)
          @formatted_row_heights ||= []
          @formatted_row_heights[lines] ||= format_inches(lines * numeric_line_height_inches)
        end
      end
    end
  end
end
