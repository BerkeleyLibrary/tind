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
          spreadsheet.write_to(out)
        end

        # @return [UCBLIT::Util::ODS::Spreadsheet] a new spreadsheet
        def spreadsheet
          @spreadsheet ||= begin
            logger.info("Creating spreadsheet for #{collection}")
            create_spreadsheet
          end
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def create_spreadsheet
          UCBLIT::Util::ODS::Spreadsheet.new.tap do |ss|
            table = ss.add_table(collection)
            add_columns(table)
            add_rows(table)
          end
        end

        def add_columns(table)
          export_table.columns.each do |export_column|
            table.add_column(
              export_column.header,
              width_for(export_column),
              protected: !export_column.can_edit?
            )
          end
        end

        def add_rows(table)
          export_table.rows.each do |export_row|
            row = table.add_row
            export_row.each_value.with_index do |v, i|
              row.set_value_at(i, v)
            end
          end
        end

        def width_for(export_column)
          value_enum = export_column.each_value(include_header: true)
          w_max = ColumnWidthCalculator.max_width_inches(value_enum)
          w_rounded = (w_max / WIDTH_ROUND_FACTOR).ceil * WIDTH_ROUND_FACTOR
          format('%0.3fin', w_rounded)
        end
      end
    end
  end
end
