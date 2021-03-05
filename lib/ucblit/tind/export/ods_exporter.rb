require 'rodf'
require 'ucblit/tind/export/exporter_base'
require 'ucblit/tind/export/odf'

module UCBLIT
  module TIND
    module Export
      # Exporter for OpenOffice/LibreOffice format
      class ODSExporter < ExporterBase

        COLUMN_WIDTH = '1in'.freeze
        LOCKED_CELL_COLOR = '#c0362c'.freeze
        STYLE_COL = 'co1'.freeze
        STYLE_CELL_DEFAULT = 'ce1'.freeze
        STYLE_CELL_LOCKED = 'ce2'.freeze

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

          # ss = ODF::ODFSpreadsheet.new do
          ss = RODF::Spreadsheet.new do
            style(STYLE_COL, family: :column) do
              property(:column, 'column-width' => COLUMN_WIDTH)
            end
            style(STYLE_CELL_DEFAULT, family: :cell) do
              property(:cell, 'cell-protect' => 'none')
            end
            style(STYLE_CELL_LOCKED, family: :cell) do
              property(:text, 'color' => LOCKED_CELL_COLOR)
              property(:cell, 'cell-protect' => 'protected')
            end
          end

          ss_table = ODF::ODFTable.new(collection)
          ss.tables << ss_table

          ss_table.row { export_table.headers.each { |h| cell(h) } }
          export_table.each_row { |r| ss_table.row { r.each_value { |v| cell(v) } } }

          each_ss_column(export_table.columns) do |ss_col|
            ss_table.columns << ss_col
          end

          ss
        end

        def each_ss_column(export_columns, &block)
          editable_count = export_columns.take_while(&:can_edit?).size
          yield ODF::ODFColumn.create(STYLE_COL, STYLE_CELL_DEFAULT, editable_count) if editable_count > 0

          remaining_columns = export_columns[editable_count..]
          return if remaining_columns.empty?

          locked_count = remaining_columns.take_while { |c| !c.can_edit? }.size
          return if locked_count == 0

          yield ODF::ODFColumn.create(STYLE_COL, STYLE_CELL_LOCKED, locked_count)

          remaining_columns = remaining_columns[locked_count..]
          each_ss_column(remaining_columns, &block) unless remaining_columns.empty?
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
