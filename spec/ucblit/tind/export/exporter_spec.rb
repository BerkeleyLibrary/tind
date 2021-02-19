require 'spec_helper'
require 'roo'

module UCBLIT
  # noinspection RubyYardParamTypeMatch
  module TIND
    describe Exporter do
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

        attr_reader :expected_table

        before(:each) do
          search_id_to_page = {
            nil => 'spec/data/records-api-search-p1.xml',
            'adBJG2ThENlR5UGc4SEFSVlM4eGQwF9B' => 'spec/data/records-api-search-p2.xml',
            'noFSHTv5UM3o0Z1NZaDNUU2kwZ1BonJ4' => 'spec/data/records-api-search.xml'
          }
          search_id_to_page.each do |search_id, body_src|
            body = File.read(body_src)
            query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search?c=Bancroft%20Library&format=xml')
            query_uri = UCBLIT::Util::URIs.append(query_uri, "&search_id=#{search_id}") if search_id
            stub_request(:get, query_uri)
              .with(headers: {
                      'Authorization' => 'Token not-a-real-api-key',
                      'Connection' => 'close',
                      'Host' => 'tind.example.org',
                      'User-Agent' => 'http.rb/4.4.1'
                    })
              .to_return(status: 200, body: body)
          end

          records = API::Search.new(collection: collection).each_result(freeze: true).to_a
          @expected_table = Export::Table.from_records(records, freeze: true)
        end

        describe :export_csv do
          it 'exports a collection' do
            expected_csv = expected_table.to_csv

            csv_str = StringIO.new.tap do |out|
              Exporter.export_csv(collection, out)
            end.string

            expect(csv_str).to eq(expected_csv)
          end
        end

        describe :export_libreoffice do
          it 'exports a collection' do
            basename = File.basename(__FILE__, '.rb')

            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              File.open(output_path, 'wb') do |f|
                # records = API::Search.new(collection: collection).each_result(freeze: true).to_a
                Exporter.export_libreoffice(collection, f)
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
        end
      end
    end
  end
end
