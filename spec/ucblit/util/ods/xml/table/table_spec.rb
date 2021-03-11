require 'spec_helper'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          describe Table do
            let(:content) { Content.new }
            let(:doc_content) { content.document_content }
            let(:table_name) { "Table for #{File.basename(__FILE__, '.rb')}" }

            attr_reader :table

            before(:each) do
              @table = doc_content.add_table(table_name)
            end

            # TODO: move to some kind of helper & share w/table_spec
            def doc_content_xml
              xml_str = content.to_xml
              File.open("tmp/content-#{Time.now.to_i}.xml", 'wb') { |f| f.write(xml_str) }
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
            end
          end
        end
      end
    end
  end
end
