require 'rodf'
require 'ucblit/util/arrays'
require 'ucblit/tind/export/exporter_base'
require 'ucblit/tind/export/odf'

module UCBLIT
  module TIND
    module Export
      # Exporter for OpenOffice/LibreOffice format
      class ODSExporter < ExporterBase

        LOCKED_CELL_COLOR = '#c0362c'.freeze

        STYLE_CELL_DEFAULT = 'ce1'.freeze
        STYLE_CELL_LOCKED = 'ce2'.freeze

        # Round column widths up to nearest `WIDTH_ROUND_FACTOR` inches
        WIDTH_ROUND_FACTOR = '1/8'.to_r

        # Pad columns out to next multiple of this
        COL_PAD_MULTIPLE = 10

        # Pad rows up to next multiple of this
        ROW_PAD_MULTIPLE = 100

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
            create_spreadsheet(all_column_styles).tap { |ss| ss.tables << create_table }
          end
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def total_rows
          @total_rows ||= ROW_PAD_MULTIPLE * ((export_table.row_count / ROW_PAD_MULTIPLE.to_f) + 0.5).ceil
        end

        def blank_row_count
          total_rows - export_table.row_count
        end


        def total_cols
          @total_cols ||= COL_PAD_MULTIPLE * ((export_table.column_count / COL_PAD_MULTIPLE.to_f) + 0.5).ceil
        end

        def blank_column_count
          total_cols - export_table.column_count
        end

        def all_column_styles
          [ODF::ColumnStyle::DEFAULT] + style_defs_by_column.values
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

        def style_defs_by_column
          @styles_by_column ||= {}.tap do |style_defs|
            styles_by_width = {}
            export_table.columns.each do |col|
              width = width_for(col)
              cs_def = (styles_by_width[width] ||= create_column_style((1 + styles_by_width.size), width))
              style_defs[col] = cs_def
            end
          end
        end

        def create_column_style(next_style_index, width)
          # co1 is the default style
          ODF::ColumnStyle.new(name: "co#{1 + next_style_index}", width: width) # TODO: wrap?
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

        def create_table
          ODF::ODFTable.new(collection).tap do |ss_table|
            each_ss_column { |ss_col| ss_table.add_column(ss_col) }
            each_ss_row { |ss_row| ss_table.add_row(ss_row) }
          end
        end

        def each_ss_column
          remaining_columns = export_table.columns
          until remaining_columns.empty?
            col_style, cell_style = column_and_cell_style_for(remaining_columns.first)
            num_repeats = 1 + UCBLIT::Util::Arrays.count_while(values: remaining_columns[1..]) do |col|
              column_and_cell_style_for(col) == [col_style, cell_style]
            end
            yield ODF::ODFColumn.repeat(num_repeats, column_style: col_style, default_cell_style: cell_style)
            remaining_columns = remaining_columns[num_repeats..]
          end
          yield repeated_blank_column if repeated_blank_column
        end

        def each_ss_row
          yield header_row
          export_table.each_row.with_index do |xr, index|
            row_number = 2 + index # row 1 is header
            row = ODF::ODFRow.new(row_number) do |r|
              xr.each_value { |v| r.cell(v) }
              r.cells << trailing_repeated_blank_cell if trailing_repeated_blank_cell
            end
            yield row
          end
          yield repeated_blank_row if repeated_blank_row
        end

        # Trailing blank columns to the right of the data.
        # If we don't add this, cells in blank columns end up protected.
        def repeated_blank_column
          return unless blank_column_count > 0

          @repeated_blank_column ||= ODF::ODFColumn.repeat(
            blank_column_count,
            column_style: ODF::ColumnStyle::DEFAULT,
            default_cell_style: STYLE_CELL_DEFAULT
          )
        end

        def header_row
          headers = export_table.headers
          ODF::ODFRow.new(1) { headers.each { |h| cell(h) } }
        end

        # Trailing blank rows below the data.
        # If we don't add this, cells in blank rows end up protected
        def repeated_blank_row
          return unless blank_row_count > 0

          @repeated_blank_row ||= ODF::ODFRow.repeat(
            blank_row_count,
            number: 1 + export_table.row_count,
            trailing_blank_cols: export_table.column_count # entire row is blank
          )
        end

        # Trailing blank cells for rows with data
        def trailing_repeated_blank_cell
          return ODF::ODFCell.repeat(blank_column_count) if blank_column_count > 0
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

      end
    end
  end
end
