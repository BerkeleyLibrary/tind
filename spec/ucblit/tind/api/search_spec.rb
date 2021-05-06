require 'spec_helper'
require 'webmock'

module UCBLIT
  module TIND
    module API
      describe Search do
        let(:base_uri) { 'https://tind.example.org/' }
        let(:api_key) { 'lorem-ipsum-dolor-sit-amet' }
        let(:query_uri) { UCBLIT::Util::URIs.append(base_uri, '/api/v1/search') }
        let(:headers) { { 'Authorization' => "Token #{api_key}" } }

        before(:each) do
          allow(UCBLIT::TIND::Config).to receive(:api_key).and_return(api_key)
          allow(UCBLIT::TIND::Config).to receive(:base_uri).and_return(base_uri)
        end

        describe 'single page' do
          let(:collection) { 'Bancroft Library' }
          let(:search) { Search.new(collection: collection) }

          before(:each) do
            body = File.read('spec/data/records-api-search.xml')
            stub_request(:get, query_uri)
              .with(headers: headers, query: { 'c' => collection, 'format' => 'xml' })
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

            query = { 'c' => collection, 'format' => 'xml' }

            stub_request(:get, query_uri)
              .with(headers: headers, query: query)
              .to_return(status: 200, body: result_xml_pages[0])

            stubs = result_xml_pages[1..].map { |b| { status: 200, body: b } }
            stub_request(:get, query_uri).with(
              headers: headers, query: query.merge({ 'search_id' => search_id })
            ).to_return(stubs)
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

        describe 'error handling' do

          describe 'Nonexistent collection' do
            let(:collection) { 'Not a collection' }
            let(:search) { Search.new(collection: collection) }
            let(:body) { '{"success": false, "error": "need more than 0 values to unpack"}' }

            before(:each) do
              stub_request(:get, query_uri)
                .with(headers: headers, query: { 'c' => collection, 'format' => 'xml' })
                .to_return(status: 500, body: body, headers: { 'Content-Type' => 'applicaton/json' })
            end

            describe :results do
              it 'returns an empty array' do
                results = search.results
                expect(results).to be_a(Array)
                expect(results.size).to eq(0)
              end
            end

            describe :each_result do
              it 'yields nothing' do
                expect { |b| search.each_result(&b) }.not_to yield_control
              end
            end
          end

          describe 'Empty result set' do
            let(:collection) { 'Restricted2Bancroft' }
            let(:search) { Search.new(collection: collection) }
            let(:body) do
              <<~XML
                <response>
                  <total>0</total>
                  <search_id>DnF1ZXJ5VGhlbkZldGNoBQAAAAACe5PjFmN0YjJMb0tKUTQtV1VfVzI2Qm8yY1EAAAAAABFKdxZuTnljT0hTU1FrMi1QSkNwVUEtZHJRAAAAAAIsSOcWSC0wU1Y0N2pRWUdodVBEdmdZUjBGUQAAAAACBSBOFjN6NGdTWWgzVFNpMGdQaDJyeGxBUncAAAAABEoXGhZ3SkFfY25BaFIzYVJMOGlDWnhxbHJn</search_id>
                  <collection xmlns="http://www.loc.gov/MARC21/slim"/>
                </response>
              XML
            end

            before(:each) do
              stub_request(:get, query_uri)
                .with(headers: headers, query: { 'c' => collection, 'format' => 'xml' })
                .to_return(status: 200, body: body, headers: { 'Content-Type' => 'applicaton/xml' })
            end

            describe :results do
              it 'returns an empty array' do
                results = search.results
                expect(results).to be_a(Array)
                expect(results.size).to eq(0)
              end
            end

            describe :each_result do
              it 'yields nothing' do
                expect { |b| search.each_result(&b) }.not_to yield_control
              end
            end
          end

          describe 'Authn/Authz' do
            let(:collection) { 'Bancroft Library' }
            let(:search) { Search.new(collection: collection) }
            let(:params) { { 'c' => collection, 'format' => 'xml' } }

            describe 'insufficient privileges' do
              # NOTE: TIND seems to return 'guest' regardless of username in the insufficient-privileges case
              let(:body) { '{"error": "User guest is not authorized to perform runapi with parameters operation=read,endpoint=search"}' }

              before(:each) do
                @query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search')

                stub_request(:get, query_uri)
                  .with(headers: headers, query: params)
                  .to_return(status: 403, body: body)
              end

              it 'raises an APIException' do
                expected_uri = UCBLIT::Util::URIs.append(query_uri, "?#{URI.encode_www_form(params)}")
                expect { search.results }.to raise_error do |e|
                  expect(e).to be_a(APIException)
                  expect(e.message).to include('403 Forbidden')
                  expect(e.message).to include(expected_uri.to_s)
                  expect(e.status_code).to eq(403)
                  expect(e.status_message).to eq('403 Forbidden')
                end
              end
            end

            describe 'API key not set' do
              it 'raises an APIException without actually performing the search' do
                allow(UCBLIT::TIND::Config).to receive(:api_key).and_return(nil)

                expected_uri = UCBLIT::Util::URIs.append(query_uri, "?#{URI.encode_www_form(params)}")
                expect { search.results }.to raise_error do |e|
                  expect(e).to be_a(APIException)
                  expect(e.message).to include(expected_uri.to_s)
                  expect(e.status_code).to eq(401)
                  expect(e.status_message).to eq('401 Unauthorized')
                end
              end
            end

            describe 'invalid API key' do
              let(:body) { '{"error": "The entered api key is invalid"}' }

              before(:each) do
                @query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search')

                stub_request(:get, query_uri)
                  .with(headers: headers, query: params)
                  .to_return(status: 401, body: body)
              end

              it 'raises an APIException' do
                expected_uri = UCBLIT::Util::URIs.append(query_uri, "?#{URI.encode_www_form(params)}")
                expect { search.results }.to raise_error do |e|
                  expect(e).to be_a(APIException)
                  expect(e.message).to include('401 Unauthorized')
                  expect(e.message).to include(expected_uri.to_s)
                  expect(e.status_code).to eq(401)
                  expect(e.status_message).to eq('401 Unauthorized')
                end
              end
            end
          end

          describe '500 (some other error)' do
            let(:collection) { 'Bancroft Library' }
            let(:search) { Search.new(collection: collection) }
            let(:params) { { 'c' => collection, 'format' => 'xml' } }

            before(:each) do
              @query_uri = UCBLIT::Util::URIs.append(base_uri, '/api/v1/search')

              stub_request(:get, query_uri)
                .with(headers: headers, query: params)
                .to_return(status: 500, body: 'oops')
            end

            describe :results do
              it 'raises an APIException' do
                expected_uri = UCBLIT::Util::URIs.append(query_uri, "?#{URI.encode_www_form(params)}")

                expect { search.results }.to raise_error do |e|
                  expect(e).to be_a(APIException)
                  expect(e.message).to include('500 Internal Server Error')
                  expect(e.message).to include(expected_uri.to_s)
                  expect(e.status_code).to eq(500)
                  expect(e.status_message).to eq('500 Internal Server Error')
                end
              end
            end

            describe :each_result do
              it 'yields nothing' do
                results = []
                expect { search.each_result { |r| results << r } }.to raise_error do |e|
                  expect(e).to be_a(APIException)
                  expect(e.message).to include('500 Internal Server Error')
                  expect(e.message).to include(query_uri.to_s)
                  expect(e.status_code).to eq(500)
                  expect(e.status_message).to eq('500 Internal Server Error')
                end
                expect(results).to be_empty
              end
            end
          end
        end

        it 'handles CJK' do
          collection = 'Houcun ju shi ji'
          search = Search.new(collection: collection)
          params = { 'c' => collection, 'format' => 'xml' }

          stub_request(:get, query_uri)
            .with(headers: headers, query: params)
            .to_return(status: 200, body: File.read('spec/data/records-api-search-cjk-p1.xml'))
          stub_request(:get, query_uri)
            .with(headers: headers, query: params.merge('search_id' => 'DnF1ZXJ5VGhlbkZldGNoBQAAAAAA'))
            .to_return(status: 200, body: File.read('spec/data/records-api-search-cjk-p2.xml'))

          results = search.results
          expect(results).to be_a(Array)
          expect(results.size).to eq(5)
        end

      end
    end
  end
end
