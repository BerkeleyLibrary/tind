require 'spec_helper'
require 'webmock'

module UCBLIT
  module TIND
    describe API do
      let(:base_uri) { 'https://tind.example.org/' }
      let(:api_key) { 'lorem-ipsum-dolor-sit-amet' }

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
