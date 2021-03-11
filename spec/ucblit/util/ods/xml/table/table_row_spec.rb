require 'spec_helper'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          describe TableRow do
            let(:content) { ContentDoc.new }
            let(:doc_content) { content.document_content }
            let(:table_name) { "Table for #{File.basename(__FILE__, '.rb')}" }

            attr_reader :table, :row

            before(:each) do
              @table = doc_content.add_table(table_name)
              table.add_column('Column 1')
              @row = table.add_row
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

            def find_row_xml(table_xml = find_table_xml, row_index = 2)
              table_xml.elements[row_index, 'table-row']
            end

            def find_cell_xml(table_xml = find_table_xml, row_index = 2, col_index = 0)
              row_xml = table_xml.elements[row_index, 'table-row']
              cells_xml = row_xml.elements.select { |e| e.name == 'table-cell' }
              cells_xml[col_index]
            end

            describe :set_value_at do
              it 'sets a value' do
                value = 'Value 0'
                row.set_value_at(0, value)
                expect(table.get_value_at(1, 0)).to eq(value)

                row_xml = find_row_xml
                cells_xml = row_xml.elements.select { |e| e.name == 'table-cell' }
                expect(cells_xml.size).to eq(2)

                cell_xml = cells_xml[0]
                p = cell_xml.elements[1, 'p'] # row 1 is header
                expect(p).to be_a(REXML::Element)
                expect(p.prefix).to eq('text')

                texts = p.texts
                expect(texts.size).to eq(1)
                expect(texts[0].value).to eq(value)

                dummy_cell_xml = cells_xml[1]
                expected_dummy_cols = Table::MIN_COLUMNS - 1
                expect(dummy_cell_xml['table:number-columns-repeated']).to eq(expected_dummy_cols.to_s)
              end

              it 'escapes tabs, newlines, and runs of spaces' do
                value_fragments = [
                  ' test test ', "\t", 'test ', ' ', ' ', 'test test', "\n", 'test test ', ' '
                ]
                value = value_fragments.join
                row.set_value_at(0, value)
                expect(table.get_value_at(1, 0)).to eq(value)

                row_xml = find_row_xml
                cells_xml = row_xml.elements.select { |e| e.name == 'table-cell' }
                expect(cells_xml.size).to eq(2)

                escape_elements = { ' ' => 's', "\t" => 'tab', "\n" => 'line-break' }

                cell_xml = cells_xml[0]
                p_xml = cell_xml.elements[1, 'p']

                p_children = p_xml.to_a
                expect(p_children.size).to eq(value_fragments.size)

                value_fragments.each_with_index do |vf, i|
                  expected_element = escape_elements[vf]
                  if expected_element
                    element = p_children[i]
                    expect(element).to be_a(REXML::Element)
                    expect(element.name).to eq(expected_element)
                    expect(element.prefix).to eq('text')
                  else
                    text = p_children[i]
                    expect(text).to be_a(REXML::Text)
                    expect(text.value).to eq(vf)
                  end
                end
              end
            end

            describe :to_xml do
              it 'collapses consecutive nils' do
                (2..7).each { |col| table.add_column("Column #{col}") }

                row.set_value_at(0, 'Value 0')
                row.set_value_at(2, 'Value 2')
                row.set_value_at(6, 'Value 6')

                row_xml = find_row_xml
                cells_xml = row_xml.elements.select { |e| e.name == 'table-cell' }
                expect(cells_xml.size).to eq(6)

                expected_values = ['Value 0', nil, 'Value 2', nil, 'Value 6', nil]
                expected_repeats = [nil, nil, nil, 3, nil, Table::MIN_COLUMNS - 7]
                cells_xml.each_with_index do |cell_xml, i|
                  p = cell_xml.elements[1, 'p']
                  if (expected_value = expected_values[i])
                    expect(p).to be_a(REXML::Element)
                    texts = p.texts
                    expect(texts.size).to eq(1)
                    expect(texts[0].value).to eq(expected_value)
                  else
                    expect(p).to be_nil
                  end

                  num_cols_repeated = cell_xml['table:number-columns-repeated']
                  expected_repeat = expected_repeats[i]
                  if expected_repeat
                    expect(num_cols_repeated).to eq(expected_repeat.to_s)
                  else
                    expect(num_cols_repeated).to be_nil
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
