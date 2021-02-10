require 'spec_helper'
require 'webmock'

module UCBLIT
  module TIND
    module API
      describe Search do
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

        describe 'single page' do
          let(:search) { Search.new(collection: 'Bancroft Library') }

          before(:each) do
            body = File.read('spec/data/records-api-search.xml')
            query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search?c=Bancroft%20Library&format=xml')
            stub_request(:get, query_uri)
              .with(headers: {
                      'Authorization' => 'Token not-a-real-api-key',
                      'Connection' => 'close',
                      'Host' => 'tind.example.org',
                      'User-Agent' => 'http.rb/4.4.1'
                    })
              .to_return(status: 200, body: body)
          end

          describe :results do
            it 'returns the results' do
              results = search.results
              expect(results).to be_a(Array)
              expect(results.size).to eq(5)
            end
          end

          describe :each_result do
            it 'iterates over the results' do
              results = []
              search.each_result { |r| results << r }
              expect(results.size).to eq(5)
            end

            it 'returns an enumerator' do
              results = []
              enum = search.each_result
              expect(enum).to be_a(Enumerable)
              enum.each { |r| results << r }
              expect(results.size).to eq(5)
            end
          end
        end

        describe 'multiple pages' do
          let(:search) { Search.new(collection: 'Bancroft Library') }

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

          describe :results do
            it 'returns the results' do
              results = search.results
              expect(results).to be_a(Array)
              expect(results.size).to eq(205)
            end
          end

          describe :each_result do
            it 'iterates over the results' do
              results = []
              search.each_result { |r| results << r }
              expect(results.size).to eq(205)
            end

            it 'returns an enumerator' do
              results = []
              enum = search.each_result
              expect(enum).to be_a(Enumerable)
              enum.each { |r| results << r }
              expect(results.size).to eq(205)
            end
          end
        end
      end
    end
  end
end
