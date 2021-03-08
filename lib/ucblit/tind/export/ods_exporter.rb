require 'rodf'
require 'ucblit/util/arrays'
require 'ucblit/tind/export/exporter_base'
require 'ucblit/tind/export/odf'

module UCBLIT
  module TIND
    module Export
      # Exporter for OpenOffice/LibreOffice format
      class ODSExporter < ExporterBase

        # Allows 9 points per 12-point character, based on  Arial average widths,
        # in units of 1/1000 point size, per
        # https://www.math.utah.edu/~beebe/fonts/afm-widths.html
        #
        # ```
        # Chars	Letters	    All	 Digits	  Upper	  Lower
        #  472	 583.44	 537.37	 556.00	 677.42	 489.46
        # ```
        WIDTH_PER_CHAR_IN = 0.125

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
            create_spreadsheet(styles_by_column.values).tap { |ss| ss.tables << create_table(export_table) }
          end
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def create_table(export_table) # pass parameter to prevent scope shenanigans
          ODF::ODFTable.new(collection).tap do |ss_table|
            ss_table.row { export_table.headers.each { |h| cell(h) } }
            export_table.each_row { |r| ss_table.row { r.each_value { |v| cell(v) } } }
            each_ss_column(export_table.columns) { |ss_col| ss_table.columns << ss_col }
          end
        end

        def create_spreadsheet(column_styles) # pass parameter to prevent scope shenanigans
          RODF::Spreadsheet.new do
            column_styles.each { |cs| style(cs[:name], family: :column) { property(:column, 'column-width' => cs[:width]) } }
            style(STYLE_CELL_DEFAULT, family: :cell) { property(:cell, 'cell-protect' => 'none') }
            style(STYLE_CELL_LOCKED, family: :cell) do
              property(:text, 'color' => LOCKED_CELL_COLOR)
              property(:cell, 'cell-protect' => 'protected')
            end
          end
        end

        def cell_style_for(export_column)
          export_column.can_edit? ? STYLE_CELL_DEFAULT : STYLE_CELL_LOCKED
        end

        def width_for(export_column)
          format('%0.3fin', (export_column.width_chars * WIDTH_PER_CHAR_IN))
        end

        def styles_by_column
          @styles_by_column ||= {}.tap do |styles|
            styles_by_width = {}
            export_table.columns.each do |col|
              width = width_for(col)
              style = (styles_by_width[width] ||= { "co#{1 + styles_by_width.size}" => width })
              styles[col] = style
            end
          end
        end

        def each_ss_column(export_columns)
          remaining_columns = export_columns
          until remaining_columns.empty?
            col_style, cell_style = column_and_cell_style_for(remaining_columns.first)
            num_repeats = 1 + UCBLIT::Util::Arrays.count_while(values: remaining_columns[1..]) do |col|
              styles_by_column[col] == col_style && cell_style_for(col) == cell_style
            end
            yield ODF::ODFColumn.create(col_style[:name], cell_style, num_repeats)
            remaining_columns = remaining_columns[num_repeats..]
          end
        end

        def column_and_cell_style_for(export_column)
          [
            styles_by_column[export_column],
            cell_style_for(export_column)
          ]
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
