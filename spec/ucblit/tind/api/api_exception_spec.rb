require 'spec_helper'
require 'rest-client'

module UCBLIT
  module TIND
    module API
      describe APIException do
        describe :wrap do
          it 'rejects nil' do
            expect { APIException.wrap(nil) }.to raise_error(ArgumentError)
          end

          describe 'RestClient::RequestFailed' do
            it 'extracts the status info and response' do
              url = 'https://example.org'
              expected_body = 'oops'
              stub_request(:get, url).to_return(status: 500, body: expected_body)

              expected_msg = 'the wrapper message'
              expect do
                begin
                  RestClient.get(url)
                rescue => e
                  raise APIException.wrap(e, msg: expected_msg)
                end
              end.to raise_error do |e|
                expect(e).to be_a(APIException)
                expect(e.cause).to be_a(RestClient::RequestFailed)
                expect(e.status_code).to eq(500)
                expect(e.status_message).to eq('500 Internal Server Error')
                expect(e.body).to eq(expected_body)
                expect(e.response).to be(e.cause.response)
              end
            end
          end

          describe 'any exception' do
            it 'wraps an exception' do
              expected_msg = 'the message'
              expect do
                begin
                  raise expected_msg
                rescue => e
                  raise APIException.wrap(e)
                end
              end.to raise_error do |e|
                expect(e).to be_a(APIException)
                expect(e.message).to eq(expected_msg)
              end
            end

            it 'overrides the message' do
              expected_msg = 'the message'
              expect do
                begin
                  raise "not #{expected_msg}"
                rescue => e
                  raise APIException.wrap(e, msg: expected_msg)
                end
              end.to raise_error do |e|
                expect(e).to be_a(APIException)
                expect(e.message).to eq(expected_msg)
              end
            end
          end
        end
      end
    end
  end
end

