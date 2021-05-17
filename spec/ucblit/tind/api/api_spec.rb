require 'spec_helper'
require 'webmock'

module UCBLIT
  module TIND
    RSpec.shared_examples 'a missing key' do |bad_key|
      before(:each) do
        expect(UCBLIT::TIND::Config).to receive(:api_key).and_return(bad_key)
      end

      it "raises #{API::APIKeyNotSet}" do
        failure_message = -> { "#{API::APIKeyNotSet} not raised for API key #{bad_key.inspect}" }
        expect { API.get('some-endpoint') }.to raise_error(API::APIKeyNotSet), failure_message
      end
    end

    RSpec.shared_examples 'a missing base URL' do |bad_url|
      before(:each) do
        allow(UCBLIT::TIND::Config).to receive(:base_uri).and_return(bad_url)
      end

      it "raises #{API::APIKeyNotSet}" do
        failure_message = -> { "#{API::BaseURINotSet} not raised for API key #{bad_url.inspect}" }
        expect { API.get('some-endpoint') }.to raise_error(API::BaseURINotSet), failure_message
      end
    end

    describe API do
      let(:base_uri) { 'https://tind.example.org/' }
      let(:api_key) { 'lorem-ipsum-dolor-sit-amet' }

      describe :get do
        describe 'with invalid API key' do
          before(:each) do
            allow(UCBLIT::TIND::Config).to receive(:base_uri).and_return(base_uri)
          end

          [nil, '', ' '].each do |bad_key|
            describe "api_key = #{bad_key.inspect}" do
              it_behaves_like 'a missing key', bad_key
            end
          end
        end
      end

      describe 'bad TIND base URI' do
        before(:each) do
          allow(UCBLIT::TIND::Config).to receive(:api_key).and_return(api_key)
        end

        [nil, '', ' '].each do |bad_url|
          describe "base_uri = #{bad_url.inspect}" do
            it_behaves_like 'a missing base URL', bad_url
          end
        end
      end

      describe 'with valid config' do
        before(:each) do
          allow(UCBLIT::TIND::Config).to receive(:base_uri).and_return(base_uri)
          allow(UCBLIT::TIND::Config).to receive(:api_key).and_return(api_key)
        end

        describe :get do
          it "raises #{API::APIException} in the event of an invalid response" do
            aggregate_failures 'responses' do
              [207, 400, 401, 403, 404, 405, 418, 451, 500, 503].each do |code|
                endpoint = "endpoint-#{code}"
                url_str = API.uri_for(endpoint).to_s
                stub_request(:get, url_str).to_return(status: code)

                expect { API.get(endpoint) }.to raise_error(API::APIException) do |e|
                  expect(e.message).to include(code.to_s)
                end
              end
            end
          end

          it 'logs the response body if an error occurs in handling' do
            endpoint = 'test-endpoint'
            url_str = API.uri_for(endpoint).to_s
            body_text = 'the body'
            stub_request(:get, url_str).to_return(status: 200, body: body_text)

            logdev = StringIO.new
            logger = UCBLIT::Logging::Loggers.new_readable_logger(logdev)
            allow(UCBLIT::Logging).to receive(:logger).and_return(logger)

            msg = 'the error message'
            expect { API.get(endpoint) { |_| raise(StandardError, msg) } }.to raise_error(StandardError, msg)
            expect(logdev.string).to include(body_text)
          end
        end
      end

      describe :format_request do
        it 'formats a request' do
          url = 'https://example.org/frob'
          params = { foo: 'bar', 'qux' => 'baz' }
          expected_url = 'https://example.org/frob?foo=bar&qux=baz'
          expect(API.format_request(url, params)).to eq("GET #{expected_url}")
        end

        it 'works without parameters' do
          url = 'https://example.org/frob'
          expect(API.format_request(url)).to eq("GET #{url}")
        end

        it 'rejects garbage parameters' do
          # noinspection RubyYardParamTypeMatch
          expect { API.format_request('https://example.org', Object.new) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
