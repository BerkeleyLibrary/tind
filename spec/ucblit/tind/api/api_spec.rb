require 'spec_helper'
require 'webmock'

module UCBLIT
  module TIND
    describe API do
      let(:base_uri) { 'https://tind.example.org/' }

      before(:each) do
        @base_uri_orig = UCBLIT::TIND::Config.instance_variable_get(:@base_uri)
        UCBLIT::TIND::Config.base_uri = base_uri
        @logger_orig = UCBLIT::TIND.logger
      end

      after(:each) do
        UCBLIT::TIND::Config.instance_variable_set(:@base_uri, @base_uri_orig)
        UCBLIT::TIND.logger = @logger_orig
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
          UCBLIT::TIND.logger = UCBLIT::Logging::Loggers.new_readable_logger(logdev)

          msg = 'the error message'
          expect { API.get(endpoint) { |_| raise(StandardError, msg) } }.to raise_error(StandardError, msg)
          puts logdev.string
          expect(logdev.string).to include(body_text)
        end
      end
    end
  end
end
