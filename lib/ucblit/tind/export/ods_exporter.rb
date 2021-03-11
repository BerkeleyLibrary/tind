require 'ucblit/util/arrays'
require 'ucblit/tind/export/exporter_base'
require 'ucblit/tind/export/column_width_calculator'
require 'ucblit/util/ods/spreadsheet'

module UCBLIT
  module TIND
    module Export
      # Exporter for OpenOffice/LibreOffice format
      class ODSExporter < ExporterBase

        LOCKED_CELL_COLOR = '#c0362c'.freeze

        # Round column widths up to nearest `WIDTH_ROUND_FACTOR` inches
        WIDTH_ROUND_FACTOR = '1/8'.to_r

        # Exports {ExportBase#collection} as an OpenOffice/LibreOffice spreadsheet
        # @overload export
        #   Exports to a new string.
        #   @return [String] a binary string containing the spreadsheet data.
        # @overload export(out)
        #   Exports to the specified output stream.
        #   @param out [IO] the output stream
        #   @return[void]
        # @overload export(path)
        #   Exports to the specified file.
        #   @param path [String, Pathname] the path to the output file
        #   @return[void]
        def export(out = nil)
          populate_spreadsheet!
          spreadsheet.write_to(out)
        end

        # ------------------------------------------------------------
        # Private methods

        private

        # ------------------------------
        # Private accessors

        def spreadsheet
          @spreadsheet ||= UCBLIT::Util::ODS::Spreadsheet.new
        end

        # @return [UCBLIT::Util::ODS::XML::Office::AutomaticStyles] the styles
        def styles
          spreadsheet.auto_styles
        end

        def protected_cell_style
          @protected_cell_style ||= styles.find_or_create_cell_style(true, LOCKED_CELL_COLOR)
        end

        # ------------------------------
        # Private utility methods

        def populate_spreadsheet!
          logger.info("Populating spreadsheet for #{collection}")

          table = spreadsheet.add_table(collection)
          add_columns(table)
          add_rows(table)
        end

        # @param table [UCBLIT::Util::ODS::XML::Table::Table] the table
        def add_columns(table)
          export_table.columns.each do |export_column|
            header = export_column.header
            column_width = width_for(export_column)

            if export_column.can_edit?
              table.add_column(header, column_width)
            else
              table.add_column_with_styles(header, column_style: column_style_for(column_width), header_cell_style: protected_cell_style)
            end
          end
        end

        def add_rows(table)
          export_table.rows.each do |export_row|
            row = table.add_row
            export_row.each_value.with_index do |v, column_index|
              cell_style = protected?(column_index) ? protected_cell_style : nil
              row.set_value_at(column_index, v, cell_style)
            end
          end
        end

        def width_for(export_column)
          value_enum = export_column.each_value(include_header: true)
          w_max = ColumnWidthCalculator.max_width_inches(value_enum)
          w_rounded = (w_max / WIDTH_ROUND_FACTOR).ceil * WIDTH_ROUND_FACTOR
          format('%0.3fin', w_rounded)
        end

        def column_style_for(width)
          styles.find_or_create_column_style(width)
        end

        def protected?(column_index)
          column = export_table.columns[column_index]
          raise ArgumentError, "Invalid column index: #{column_index.inspect}" unless column

          !column.can_edit?
        end
      end
    end
  end
end
