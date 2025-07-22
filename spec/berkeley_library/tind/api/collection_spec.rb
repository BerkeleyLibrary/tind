require 'spec_helper'
require 'webmock'

module BerkeleyLibrary
  module TIND
    module API
      describe Collection do
        let(:base_uri) { 'https://tind.example.org/' }
        let(:api_key) { 'not-a-real-api-key' }

        before(:each) do
          @base_uri_orig = BerkeleyLibrary::TIND::Config.instance_variable_get(:@base_uri)
          BerkeleyLibrary::TIND::Config.base_uri = base_uri

          @api_key_orig = BerkeleyLibrary::TIND::Config.instance_variable_get(:@api_key)
          BerkeleyLibrary::TIND::Config.api_key = api_key
        end

        after(:each) do
          BerkeleyLibrary::TIND::Config.instance_variable_set(:@base_uri, @base_uri_orig)
          BerkeleyLibrary::TIND::Config.instance_variable_set(:@api_key, @api_key_orig)
        end

        describe :all do
          it 'reads the collections from the API' do
            query_uri = BerkeleyLibrary::Util::URIs.append(base_uri, '/api/v1/collections?depth=100')
            stub_request(:get, query_uri)
              .with(headers: { 'Authorization' => 'Token not-a-real-api-key' })
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

          it 'returns an empty array in the event of an error' do
            query_uri = BerkeleyLibrary::Util::URIs.append(base_uri, '/api/v1/collections?depth=100')
            stub_request(:get, query_uri).to_return(status: 404)

            expect(Collection.all).to eq([])
          end

          it 'raises an error if the API key is not set' do
            BerkeleyLibrary::TIND::API.instance_variable_set(:@api_key, nil)
          end
        end

        describe :each_collection do
          it 'yields each collection' do
            collections_json = File.read('spec/data/collections.json')
            expected_names = File.readlines('spec/data/collection-names.txt', chomp: true)

            query_uri = BerkeleyLibrary::Util::URIs.append(base_uri, '/api/v1/collections?depth=100')
            stub_request(:get, query_uri)
              .with(headers: { 'Authorization' => 'Token not-a-real-api-key' })
              .to_return(status: 200, body: collections_json)

            actual_names = Collection.each_collection.with_object([]) { |c, arr| arr << c.name }
            expect(actual_names).to contain_exactly(*expected_names)
          end
        end
      end
    end
  end
end
