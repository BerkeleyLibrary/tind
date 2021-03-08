require 'rodf'
require 'ucblit/util/arrays'
require 'ucblit/tind/export/exporter_base'
require 'ucblit/tind/export/odf'

module UCBLIT
  module TIND
    module Export
      # Exporter for OpenOffice/LibreOffice format
      class ODSExporter < ExporterBase

        # Round column widths up to nearest `WIDTH_ROUND_FACTOR` inches
        WIDTH_ROUND_FACTOR = '1/8'.to_r

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
            logger.info("Creating spreadsheet for #{collection}")
            create_spreadsheet(style_defs_by_column.values).tap { |ss| ss.tables << create_table(export_table) }
          end
        end

        # ------------------------------------------------------------
        # Private methods

        private

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

        def style_defs_by_column
          @styles_by_column ||= {}.tap do |style_defs|
            styles_by_width = {}
            export_table.columns.each do |col|
              width = width_for(col)
              cs_def = (styles_by_width[width] ||= ColumnStyleDef.new(name: "co#{1 + styles_by_width.size}", width: width))
              style_defs[col] = cs_def
            end
          end
        end

        # NOTE: we pass column_styles as a parameter to prevent RODF DSL scope shenanigans
        def create_spreadsheet(column_style_defs)
          RODF::Spreadsheet.new do
            column_style_defs.each do |cs_def|
              style(cs_def.name, family: :column) { property(:column, 'column-width' => cs_def.width) }
            end
            style(STYLE_CELL_DEFAULT, family: :cell) { property(:cell, 'cell-protect' => 'none') }
            style(STYLE_CELL_LOCKED, family: :cell) do
              property(:text, 'color' => LOCKED_CELL_COLOR)
              property(:cell, 'cell-protect' => 'protected')
            end
          end
        end

        # NOTE: we pass export_table as a parameter to prevent RODF DSL scope shenanigans
        def create_table(export_table)
          ODF::ODFTable.new(collection).tap do |ss_table|
            ss_table.row { export_table.headers.each { |h| cell(h) } }
            export_table.each_row { |r| ss_table.row { r.each_value { |v| cell(v) } } }
            each_ss_column { |ss_col| ss_table.columns << ss_col }
          end
        end

        def each_ss_column
          remaining_columns = export_table.columns
          until remaining_columns.empty?
            col_style, cell_style = column_and_cell_style_for(remaining_columns.first)
            num_repeats = 1 + UCBLIT::Util::Arrays.count_while(values: remaining_columns[1..]) do |col|
              column_and_cell_style_for(col) == [col_style, cell_style]
            end
            yield ODF::ODFColumn.create(col_style, cell_style, num_repeats)
            remaining_columns = remaining_columns[num_repeats..]
          end
        end

        def width_for(export_column)
          w_header = ODF::Width.width_inches(export_column.header)
          w_max = export_column.each_value.inject(w_header) do |current, s|
            width_inches = ODF::Width.width_inches(s)
            [current, width_inches].max
          end
          w_rounded = (w_max / WIDTH_ROUND_FACTOR).ceil * WIDTH_ROUND_FACTOR
          format('%0.3fin', w_rounded)
        end

        def column_style_name_for(export_column)
          style_defs_by_column[export_column].name
        end

        def cell_style_name_for(export_column)
          export_column.can_edit? ? STYLE_CELL_DEFAULT : STYLE_CELL_LOCKED
        end

        def column_and_cell_style_for(export_column)
          [
            column_style_name_for(export_column),
            cell_style_name_for(export_column)
          ]
        end

        # ------------------------------------------------------------
        # Helper classes

        class ColumnStyleDef
          attr_reader :name, :width

          def initialize(name:, width:)
            @name = name
            @width = width
          end

          def to_s
            "name: #{name}, width: #{width}"
          end
        end

      end
    end
  end
end
