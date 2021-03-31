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

          @api_key_orig = UCBLIT::TIND::Config.instance_variable_get(:@api_key)
          UCBLIT::TIND::Config.api_key = api_key
        end

        after(:each) do
          UCBLIT::TIND::Config.instance_variable_set(:@base_uri, @base_uri_orig)
          UCBLIT::TIND::Config.instance_variable_set(:@api_key, @api_key_orig)
        end

        describe 'single page' do
          let(:search) { Search.new(collection: 'Bancroft Library') }

          before(:each) do
            body = File.read('spec/data/records-api-search.xml')
            query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search?c=Bancroft%20Library&format=xml')
            stub_request(:get, query_uri)
              .with(headers: { 'Authorization' => 'Token not-a-real-api-key' })
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

            describe :freeze do
              describe 'with block' do
                it 'defaults to false' do
                  search.each_result do |marc_record|
                    expect(marc_record).not_to be_frozen
                  end
                end

                it 'freezes results if true' do
                  search.each_result(freeze: true) do |marc_record|
                    expect(marc_record).to be_frozen
                  end
                end
              end

              describe 'as enumerator' do
                it 'defaults to false' do
                  enum = search.each_result
                  enum.each do |marc_record|
                    expect(marc_record).not_to be_frozen
                  end
                end

                it 'freezes results if true' do
                  enum = search.each_result(freeze: true)
                  enum.each do |marc_record|
                    expect(marc_record).to be_frozen
                  end
                end
              end
            end
          end
        end

        describe 'multiple pages' do
          let(:collection) { 'Bancroft Library' }
          let(:search) { Search.new(collection: collection) }
          let(:search_id) { 'DnF1ZXJ5VGhlbkZldG' }
          let(:expected_count) { 554 }

          before(:each) do
            result_xml_pages = (1..7).map { |page| File.read("spec/data/records-api-search-p#{page}.xml") }

            query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search?c=Bancroft%20Library&format=xml')
            headers = { 'Authorization' => 'Token not-a-real-api-key' }

            stub_request(:get, query_uri)
              .with(headers: headers).to_return(status: 200, body: result_xml_pages[0])

            query_uri = UCBLIT::Util::URIs.append(query_uri, "&search_id=#{search_id}")
            stubs = result_xml_pages[1..].map { |b| { status: 200, body: b } }
            stub_request(:get, query_uri).with(headers: headers).to_return(stubs)
          end

          describe :results do
            it 'returns the results' do
              results = search.results
              expect(results).to be_a(Array)
              expect(results.size).to eq(expected_count)

              first = results.first
              expect(first).to be_a(::MARC::Record)
              expect(first['024']['a']).to eq('BANC PIC 1958.021 Vol. 2:001--fALB')

              last = results.last
              expect(last).to be_a(::MARC::Record)
              expect(last['024']['a']).to eq('BANC PIC 1958.021 Vol. 3:162--fALB')
            end
          end

          describe :each_result do
            it 'iterates over the results' do
              results = []
              search.each_result { |r| results << r }
              expect(results.size).to eq(expected_count)
            end

            it 'returns an enumerator' do
              results = []
              enum = search.each_result
              expect(enum).to be_a(Enumerable)
              enum.each { |r| results << r }
              expect(results.size).to eq(expected_count)
            end

            describe :freeze do
              describe 'with block' do
                it 'defaults to false' do
                  search.each_result do |marc_record|
                    expect(marc_record).not_to be_frozen
                  end
                end

                it 'freezes results if true' do
                  search.each_result(freeze: true) do |marc_record|
                    expect(marc_record).to be_frozen
                  end
                end
              end

              describe 'as enumerator' do
                it 'defaults to false' do
                  enum = search.each_result
                  enum.each do |marc_record|
                    expect(marc_record).not_to be_frozen
                  end
                end

                it 'freezes results if true' do
                  enum = search.each_result(freeze: true)
                  enum.each do |marc_record|
                    expect(marc_record).to be_frozen
                  end
                end
              end
            end
          end
        end

        it 'handles CJK' do
          query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search?c=Houcun%20ju%20shi%20ji&format=xml')
          headers = { 'Authorization' => 'Token not-a-real-api-key' }
          stub_request(:get, query_uri).with(headers: headers)
            .to_return(status: 200, body: File.read('spec/data/records-api-search-cjk-p1.xml'))
          query_uri = UCBLIT::Util::URIs.append(query_uri, '&search_id=DnF1ZXJ5VGhlbkZldGNoBQAAAAAA')
          stub_request(:get, query_uri).with(headers: headers)
            .to_return(status: 200, body: File.read('spec/data/records-api-search-cjk-p2.xml'))

          search = Search.new(collection: 'Houcun ju shi ji')
          results = search.results
          expect(results).to be_a(Array)
          expect(results.size).to eq(5)
        end
      end
    end
  end
end
