require 'rodf'
require 'ucblit/util/arrays'
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

        def create_spreadsheet(collection, export_table)
          logger.info("Creating spreadsheet for #{collection}")

          new_spreadsheet.tap do |ss|
            ss.tables << new_table(collection, export_table)
          end
        end

        # TODO: lock cells, not columns
        def new_table(collection, export_table)
          ss_table = ODF::ODFTable.new(collection)
          ss_table.row { export_table.headers.each { |h| cell(h) } }
          export_table.each_row { |r| ss_table.row { r.each_value { |v| cell(v) } } }

          each_ss_column(export_table.columns) do |ss_col|
            ss_table.columns << ss_col
          end
          ss_table
        end

        def new_spreadsheet
          RODF::Spreadsheet.new do
            style(STYLE_COL, family: :column) { property(:column, 'column-width' => COLUMN_WIDTH) }
            style(STYLE_CELL_DEFAULT, family: :cell) { property(:cell, 'cell-protect' => 'none') }
            style(STYLE_CELL_LOCKED, family: :cell) do
              property(:text, 'color' => LOCKED_CELL_COLOR)
              property(:cell, 'cell-protect' => 'protected')
            end
          end
        end

        # TODO: set column width
        def cell_style_for(export_column)
          export_column.can_edit? ? STYLE_CELL_DEFAULT : STYLE_CELL_LOCKED
        end

        def each_ss_column(export_columns)
          remaining_columns = export_columns
          until remaining_columns.empty?
            first_column_style = cell_style_for(remaining_columns.first)
            num_repeats = 1 + UCBLIT::Util::Arrays.count_while(values: remaining_columns[1..]) { |c| cell_style_for(c) == first_column_style }
            yield ODF::ODFColumn.create(STYLE_COL, first_column_style, num_repeats)
            remaining_columns = remaining_columns[num_repeats..]
          end
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
