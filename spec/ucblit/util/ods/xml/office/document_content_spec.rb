require 'spec_helper'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          describe DocumentContent do
            let(:content) { ContentDoc.new }
            let(:doc_content) { content.document_content }

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

            describe :add_table do

              let(:table_name) { "Table for #{File.basename(__FILE__, '.rb')}" }

              attr_reader :table

              before(:each) do
                @table = doc_content.add_table(table_name)
              end

              it 'creates a table' do
                expect(table).to be_a(XML::Table::Table)
              end

              it 'adds the table to the XML' do
                table_xml = find_table_xml
                expect(table_xml).to be_a(REXML::Element)
                expect(table_xml.prefix).to eq('table')
                expect(table_xml.name).to eq('table')

                expect(table_xml['table:name']).to eq(table_name)
                expect(table_xml['table:protected']).to eq('true')
              end
            end
          end
        end
      end
    end
  end
end
