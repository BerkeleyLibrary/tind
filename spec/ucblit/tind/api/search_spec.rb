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

        describe :result do
          it 'performs a search' do
            search = Search.new(collection: 'Bancroft Library')

            expected_body = File.read('spec/data/records-api-search.xml')
            query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search?c=Bancroft%20Library&format=xml')
            stub_request(:get, query_uri)
              .with(headers: {
                      'Authorization' => 'Token not-a-real-api-key',
                      'Connection' => 'close',
                      'Host' => 'tind.example.org',
                      'User-Agent' => 'http.rb/4.4.1'
                    })
              .to_return(status: 200, body: expected_body)

            expect(search.result).to eq(expected_body)
          end
        end
      end
    end
  end
end
