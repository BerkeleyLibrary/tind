require 'spec_helper'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          describe Table do
            let(:content) { ContentDoc.new }
            let(:doc_content) { content.document_content }
            let(:table_name) { "Table for #{File.basename(__FILE__, '.rb')}" }

            attr_reader :table

            before(:each) do
              @table = doc_content.add_table(table_name)
            end

            # TODO: move to some kind of helper & share w/table_spec
            def doc_content_xml
              xml_str = content.to_xml
              # File.open("tmp/content-#{Time.now.to_i}.xml", 'wb') { |f| f.write(xml_str) }
              rexml_doc = REXML::Document.new(xml_str)
              rexml_doc.root
            end

            # TODO: move to some kind of helper & share w/table_spec
            def find_table_xml(dc_xml = doc_content_xml, table_index = 1)
              body = dc_xml.elements[4]
              expect(body).to be_a(REXML::Element) # just to be sure

              spreadsheet = body.elements[1]
              expect(spreadsheet).to be_a(REXML::Element) # just to be sure

              spreadsheet.elements[table_index]
            end

            describe :add_column do
              attr_reader :header_str
              attr_reader :width
              attr_reader :col

              before(:each) do
                timestamp = Time.now.to_i
                @header_str = "Header #{timestamp}"
                @width = "#{timestamp % 10}.#{timestamp % 100}.in"
                @col = table.add_column(header_str, width)
              end

              it 'adds a column' do
                expect(col).to be_a(TableColumn)
              end

              it 'sets the header' do
                expect(table.get_value_at(0, 0)).to eq(header_str)
              end

              it 'creates an associated style' do
                styles = doc_content.automatic_styles
                col_style = styles.find_column_style(width)
                expect(col_style).to be_a(Style::ColumnStyle)

                expect(col.column_style).to be(col_style)

                dc_xml = doc_content_xml
                styles_xml = dc_xml.elements[1, 'automatic-styles']
                expect(styles_xml).to be_a(REXML::Element) # just to be sure

                style_xml = styles_xml.elements.find do |elem|
                  elem.prefix == 'style' &&
                    elem.name == 'style' &&
                    elem['style:family'] == 'table-column' &&
                    elem['style:name'] == col_style.style_name
                end
                expect(style_xml).to be_a(REXML::Element)

                props_xml = style_xml.elements[1]
                expect(props_xml.prefix).to eq('style')
                expect(props_xml.name).to eq('table-column-properties')
                expect(props_xml['style:column-width']).to eq(width)
              end

              it 'writes the column to XML' do
                col_style = doc_content.automatic_styles.find_column_style(width)

                table_xml = find_table_xml
                col_xml = table_xml.elements[1, 'table-column']
                expect(col_xml).to be_a(REXML::Element)
                expect(col_xml.prefix).to eq('table')
                expect(col_xml['table:style-name']).to eq(col_style.style_name)
              end

              describe 'protected' do
                attr_reader :pcol

                before(:each) do
                  timestamp = Time.now.to_i
                  header_str = "Protected #{timestamp}"
                  @pcol = table.add_column(header_str, protected: true)
                end

                it 'adds a column' do
                  expect(pcol).to be_a(TableColumn)
                end

                it 'adds a protected cell style' do
                  col_style = pcol.column_style

                  default_cell_style = pcol.default_cell_style
                  expect(default_cell_style.protected?).to eq(true)

                  table_xml = find_table_xml
                  col_xml = table_xml.elements[2, 'table-column']
                  expect(col_xml['table:style-name']).to eq(col_style.style_name)
                  expect(col_xml['table:default-cell-style-name']).to eq(default_cell_style.style_name)
                end
              end
            end

            describe :to_xml do
              let(:columns_added) { 15 }
              let(:expected_dummy_cols) { Table::MIN_COLUMNS - columns_added }

              describe 'column repeats' do

                it 'adds dummy columns as needed' do
                  expected_dummy_cols = Table::MIN_COLUMNS - columns_added
                  columns_added.times { |col| table.add_column("Column #{col}", "1.#{col}in") }

                  table_xml = find_table_xml
                  columns_xml = table_xml.elements.select { |e| e.name == 'table-column' }
                  expect(columns_xml.size).to eq(columns_added + 1)

                  dummy_column_xml = columns_xml.last
                  expect(dummy_column_xml['table:number-columns-repeated']).to eq(expected_dummy_cols.to_s)

                  header_row_xml = table_xml.elements[1, 'table-row']
                  header_cells_xml = header_row_xml.elements.select { |e| e.name == 'table-cell' }
                  expect(header_cells_xml.size).to eq(columns_added + 1)

                  columns_added.times do |col|
                    expected_header = "Column #{col}"
                    expect(table.get_value_at(0, col)).to eq(expected_header) # just to be sure

                    header_cell_xml = header_cells_xml[col]
                    header_p = header_cell_xml.elements[1, 'p']
                    header_texts = header_p.texts
                    expect(header_texts.size).to eq(1)

                    expect(header_texts[0].value).to eq(expected_header)
                  end

                  dummy_cell_xml = header_cells_xml.last
                  expect(dummy_cell_xml['table:number-columns-repeated']).to eq(expected_dummy_cols.to_s)
                end

                it 'uses repeats for identical columns' do
                  columns_added.times { |col| table.add_column("Column #{col}") }

                  table_xml = find_table_xml
                  columns_xml = table_xml.elements.select { |e| e.name == 'table-column' }
                  expect(columns_xml.size).to eq(2)

                  repeated_column_xml = columns_xml[0]
                  expect(repeated_column_xml['table:number-columns-repeated']).to eq(columns_added.to_s)

                  dummy_column_xml = columns_xml.last
                  expect(dummy_column_xml['table:number-columns-repeated']).to eq(expected_dummy_cols.to_s)
                end

              end

              describe 'dummy rows' do
                let(:rows_added) { 15 }

                it 'adds dummy rows as needed' do
                  columns_added.times { |col| table.add_column("Column #{col}") }
                  rows_added.times do |r|
                    row = table.add_row
                    columns_added.times do |c|
                      value = "value for (#{r + 1}, c)"
                      row.set_value_at(c, value)
                    end
                  end

                  columns_added.times do |c|
                    expect(table.get_value_at(0, c)).to eq("Column #{c}")
                    rows_added.times do |r|
                      value = "value for (#{r + 1}, c)" # skip header row
                      expect(table.get_value_at(r + 1, c)).to eq(value)
                    end
                  end

                  table_xml = find_table_xml
                  rows_xml = table_xml.elements.select { |e| e.name == 'table-row' }
                  expect(rows_xml.size).to eq(2 + rows_added)

                  # TODO: do we need a final unrepeated row?
                  expected_dummy_rows = Table::MIN_ROWS - (1 + rows_added)
                  dummy_row_xml = rows_xml.last
                  expect(dummy_row_xml['table:number-rows-repeated']).to eq(expected_dummy_rows.to_s)

                  dummy_cells_xml = dummy_row_xml.elements.select { |e| e.name == 'table-cell' }
                  expect(dummy_cells_xml.size).to eq(1)

                  dummy_cell_xml = dummy_cells_xml[0]
                  expect(dummy_cell_xml['table:number-columns-repeated']).to eq(Table::MIN_COLUMNS.to_s)
                end

              end
            end

          end
        end
      end
    end
  end
end
