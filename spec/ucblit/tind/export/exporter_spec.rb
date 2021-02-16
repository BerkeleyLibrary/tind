require 'spec_helper'

module UCBLIT
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

      describe :export do
        let(:collection) { 'Bancroft Library' }

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
        end

        it 'exports a collection' do
          records = API::Search.new(collection: collection).each_result(freeze: true).to_a

          csv_str = StringIO.new.tap do |out|
            Exporter.export(collection, out)
          end.string

          aggregate_failures 'rows' do
            CSV.parse(csv_str, headers: true).each_with_index do |csv_row, row|
              marc_record = records[row]
              csv_row.headers.each do |header|
                values = marc_record.values_for(header)

                value = csv_row[header]
                if values.empty?
                  expect(value).to be_nil, "#{header}: expected no values in row/record #{row}, got #{value.inspect}"
                else
                  expect(values).to include(value), "#{header}: expected one of: #{values.inspect}, got #{value.inspect}"
                end
              end
            end
          end
        end
      end
    end
  end
end
