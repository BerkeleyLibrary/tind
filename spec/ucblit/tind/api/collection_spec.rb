require 'spec_helper'
require 'webmock'

module UCBLIT
  module TIND
    module API
      describe Collection do
        let(:base_uri) { 'https://tind.example.org/' }
        let(:api_key) { 'not-a-real-api-key' }

        around(:each) do |example|
          base_uri_orig = UCBLIT::TIND::Config.instance_variable_get(:@base_uri)
          api_key_orig = UCBLIT::TIND::API.instance_variable_get(:@api_key)
          UCBLIT::TIND::Config.base_uri = base_uri
          UCBLIT::TIND::API.api_key = api_key
          example.run
          UCBLIT::TIND::Config.instance_variable_set(:@base_uri, base_uri_orig)
          UCBLIT::TIND::API.instance_variable_set(:@api_key, api_key_orig)
        end

        describe :all do
          it 'reads the collections from the API' do
            # TODO: sort this out
            stub_request(:get, "#{base_uri}/api/v1/collection?depth=100")
              .with(headers: {
                      'Authorization' => 'Token not-a-real-api-key',
                      'Connection' => 'close',
                      'Host' => 'tind.example.org',
                      'User-Agent' => 'http.rb/4.4.1'
                    })
              .to_return(status: 200, body: File.read('spec/data/collections.json'))

            all_collections = Collection.all
            expect(all_collections.size).to eq(1)
            expect(all_collections.size).to be_a(Array) # TODO: hmm
          end
        end
      end
    end
  end
end
