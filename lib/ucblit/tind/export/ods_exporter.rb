require 'rodf'
require 'ucblit/tind/export/exporter_base'
require 'ucblit/tind/export/odf'

module UCBLIT
  module TIND
    module Export
      # Exporter for OpenOffice/LibreOffice format
      class ODSExporter < ExporterBase

        COLUMN_WIDTH = '1.0in'.freeze
        LOCKED_CELL_COLOR = '#c0362c'.freeze
        STYLE_COL_DEFAULT = 'column-default'.freeze
        STYLE_COL_LOCKED = 'column-locked'.freeze
        STYLE_CELL_DEFAULT = 'cell-default'.freeze
        STYLE_CELL_LOCKED = 'cell-locked'.freeze

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
          return write_spreadsheet_to_string unless out
          return write_spreadsheet_to_stream(out) if out.respond_to?(:write)

          # noinspection RubyYardReturnMatch
          write_spreadsheet_to_file(out)
        end

        def spreadsheet
          @spreadsheet ||= begin
            create_spreadsheet(collection, export_table)
          end
        end

        private

        # TODO: clean this up
        def create_spreadsheet(collection, export_table)
          logger.info("Creating spreadsheet for #{collection}")

          ss = RODF::Spreadsheet.new do
            style(STYLE_CELL_DEFAULT, family: :cell) do
              property(:cell, 'cell-protect' => 'none')
            end
            style(STYLE_CELL_LOCKED, family: :cell) do
              property(:text, 'color' => LOCKED_CELL_COLOR)
              property(:cell, 'cell-protect' => 'protected')
            end
            style(STYLE_COL_DEFAULT, family: :column) do
              property(:column, 'column-width' => COLUMN_WIDTH)
            end
            style(STYLE_COL_LOCKED, family: :column) do
              property(:text, 'color' => LOCKED_CELL_COLOR)
              property(:column, 'column-width' => COLUMN_WIDTH)
            end
          end

          ss_table = ODF::ODFTable.new(collection)
          ss.tables << ss_table

          ss_table.row { export_table.headers.each { |h| cell(h) } }
          export_table.each_row { |r| ss_table.row { r.each_value { |v| cell(v) } } }

          export_table.columns.each do |col|
            col_style = col.can_edit? ? STYLE_COL_DEFAULT : STYLE_COL_LOCKED
            cell_style = col.can_edit? ? STYLE_CELL_DEFAULT : STYLE_CELL_LOCKED
            ss_col = ODF::ODFColumn.new(
              style: col_style,
              default_cell_style_name: cell_style
            )
            ss_table.columns << ss_col
          end

          ss
        end

        def write_spreadsheet_to_string
          StringIO.new.tap do |out|
            out.write(spreadsheet.bytes)
          end.string
        end

        def write_spreadsheet_to_stream(out)
          out.write(spreadsheet.bytes)
        end

        def write_spreadsheet_to_file(path)
          File.open(path, 'wb') { |f| write_spreadsheet_to_stream(f) }
        end
      end
    end
  end
end
