require 'spec_helper'
require 'roo'

module UCBLIT
  # noinspection RubyYardParamTypeMatch
  module TIND
    describe Export do
      let(:base_uri) { 'https://tind.example.org/' }
      let(:api_key) { 'not-a-real-api-key' }

      before(:each) do
        @base_uri_orig = UCBLIT::TIND::Config.instance_variable_get(:@base_uri)
        UCBLIT::TIND::Config.base_uri = base_uri

        @api_key_orig = UCBLIT::TIND::API.instance_variable_get(:@api_key)
        UCBLIT::TIND::API.api_key = api_key
      end

      after(:each) do
        UCBLIT::TIND::Config.instance_variable_set(:@base_uri, @base_uri_orig)
        UCBLIT::TIND::API.instance_variable_set(:@api_key, @api_key_orig)
      end

      describe 'export' do
        let(:collection) { 'Bancroft Library' }
        let(:search) { Search.new(collection: collection) }
        let(:search_id) { 'DnF1ZXJ5VGhlbkZldG' }
        let(:expected_count) { 554 }

        attr_reader :expected_table

        before(:each) do
          result_xml_pages = (1..7).map { |page| File.read("spec/data/records-api-search-p#{page}.xml") }

          query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search?c=Bancroft%20Library&format=xml')
          headers = {
            'Authorization' => 'Token not-a-real-api-key',
            'Connection' => 'close',
            'Host' => 'tind.example.org',
            'User-Agent' => 'http.rb/4.4.1'
          }

          stub_request(:get, query_uri)
            .with(headers: headers).to_return(status: 200, body: result_xml_pages[0])

          query_uri = UCBLIT::Util::URIs.append(query_uri, "&search_id=#{search_id}")
          stubs = result_xml_pages[1..].map { |b| { status: 200, body: b } }
          stub_request(:get, query_uri).with(headers: headers).to_return(stubs)

          expected_records = Enumerator.new do |y|
            result_xml_pages.each do |xml_page|
              reader = UCBLIT::TIND::MARC::XMLReader.new(xml_page, freeze: true)
              reader.each { |marc_record| y << marc_record }
            end
          end
          @expected_table = Export::Table.from_records(expected_records, freeze: true)
        end

        describe :export_csv do
          it 'exports a collection' do
            expected_csv = expected_table.to_csv

            actual_csv = StringIO.new.tap do |out|
              Export.export_csv(collection, out)
            end.string

            File.open('tmp/actual.csv', 'wb') { |f| f.write(actual_csv) }
            File.open('tmp/expected.csv', 'wb') { |f| f.write(expected_csv) }
            expect(actual_csv).to eq(expected_csv)
          end
        end

        describe :export_libreoffice do
          it 'exports a collection' do
            basename = File.basename(__FILE__, '.rb')

            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              File.open(output_path, 'wb') do |f|
                # records = API::Search.new(collection: collection).each_result(freeze: true).to_a
                Export.export_libreoffice(collection, f)
              end

              ss = Roo::Spreadsheet.open(output_path)

              # NOTE: spreadsheets are 1-indexed, but row 1 is header

              aggregate_failures 'headers' do
                expected_table.headers.each_with_index do |h, col|
                  ss_col = 1 + col
                  actual_header = ss.cell(1, ss_col)
                  expect(actual_header).to eq(h), "Expected header #{h.inspect} for column #{ss_col}, got #{actual_header.inspect}"
                end
              end

              aggregate_failures 'values' do
                (0..expected_table.row_count).each do |row|
                  ss_row = 2 + row # row 1 is header
                  (0..expected_table.column_count).each do |col|
                    ss_col = 1 + col
                    expected_value = expected_table.value_at(row, col)
                    actual_value = ss.cell(ss_row, ss_col)
                    expect(actual_value).to eq(expected_value), "(#{ss_row}, #{ss_col}): expected #{expected_value.inspect}, got #{actual_value.inspect}"
                  end
                end
              end

              ss.close
            end
          end

          it 'exports to a file' do
            basename = File.basename(__FILE__, '.rb')
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              Export.export_libreoffice(collection, output_path)

              ss = Roo::Spreadsheet.open(output_path)

              # NOTE: spreadsheets are 1-indexed, but row 1 is header

              aggregate_failures 'headers' do
                expected_table.headers.each_with_index do |h, col|
                  ss_col = 1 + col
                  actual_header = ss.cell(1, ss_col)
                  expect(actual_header).to eq(h), "Expected header #{h.inspect} for column #{ss_col}, got #{actual_header.inspect}"
                end
              end

              aggregate_failures 'values' do
                (0..expected_table.row_count).each do |row|
                  ss_row = 2 + row # row 1 is header
                  (0..expected_table.column_count).each do |col|
                    ss_col = 1 + col
                    expected_value = expected_table.value_at(row, col)
                    actual_value = ss.cell(ss_row, ss_col)
                    expect(actual_value).to eq(expected_value), "(#{ss_row}, #{ss_col}): expected #{expected_value.inspect}, got #{actual_value.inspect}"
                  end
                end
              end

              ss.close
            end
          end
        end
      end
    end
  end
end
