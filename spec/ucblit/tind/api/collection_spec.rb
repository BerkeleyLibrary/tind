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
            query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/collection?depth=100')
            stub_request(:get, query_uri)
              .with(headers: {
                      'Authorization' => 'Token not-a-real-api-key',
                      'Connection' => 'close',
                      'Host' => 'tind.example.org',
                      'User-Agent' => 'http.rb/4.4.1'
                    })
              .to_return(status: 200, body: File.read('spec/data/collections.json'))

            all_collections = Collection.all
            expect(all_collections.size).to eq(1)
            expect(root_collection = all_collections.first).not_to be_nil
            expect(root_collection.name).to eq('Digital Collections')

            top_level_collections = root_collection.children
            expect(top_level_collections.map(&:name)).to eq(['Bampfa', 'Bancroft Library', 'Berkeley Library', 'East Asian Library', 'Humanities & Social Sciences', 'Sciences'])

            bancroft = top_level_collections.find { |c| c.name == 'Bancroft Library' }
            examiner = bancroft.children.find { |c| c.name == 'SFExaminer' }
            expect(examiner.name_en).to eq('San Francisco Examiner')
            expect(examiner.size).to eq(15_564)
          end
        end
      end
    end
  end
end
