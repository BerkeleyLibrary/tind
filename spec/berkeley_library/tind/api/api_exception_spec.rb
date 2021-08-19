require 'spec_helper'
require 'rest-client'

module BerkeleyLibrary
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
              params = { 'foo' => 'bar' }
              expected_body = 'oops'
              stub_request(:get, url).with(query: params).to_return(status: 500, body: expected_body)

              expected_msg = 'the wrapper message'
              expect do
                RestClient.get(url, params: params)
              rescue StandardError => e
                raise APIException.wrap(e, url: url, params: params, detail: expected_msg)
              end.to raise_error do |e|
                expect(e).to be_a(APIException)
                expect(e.cause).to be_a(RestClient::RequestFailed)
                expect(e.status_code).to eq(500)
                expect(e.status_message).to eq('500 Internal Server Error')
                expect(e.body).to eq(expected_body)
                expect(e.response).to be(e.cause.response)
                expect(e.url).to eq(url)
                expect(e.params).to eq(params)
              end
            end

            it 'works with or without parameters' do
              url = 'https://example.org'
              expected_body = 'oops'
              stub_request(:get, url).to_return(status: 500, body: expected_body)

              expected_msg = 'the wrapper message'
              expect do
                RestClient.get(url)
              rescue StandardError => e
                raise APIException.wrap(e, url: url, detail: expected_msg)
              end.to raise_error do |e|
                expect(e).to be_a(APIException)
                expect(e.cause).to be_a(RestClient::RequestFailed)
                expect(e.status_code).to eq(500)
                expect(e.status_message).to eq('500 Internal Server Error')
                expect(e.body).to eq(expected_body)
                expect(e.response).to be(e.cause.response)
                expect(e.url).to eq(url)
                expect(e.params).to be_nil
              end
            end
          end

          describe 'any exception' do
            it 'wraps an exception' do
              expected_msg = 'the message'
              expect do

                raise expected_msg
              rescue StandardError => e
                raise APIException.wrap(e)
              end.to raise_error do |e|
                expect(e).to be_a(APIException)
                expect(e.message).to eq(expected_msg)
              end
            end

            it 'overrides the message' do
              expected_msg = 'the message'
              expect do

                raise "not #{expected_msg}"
              rescue StandardError => e
                raise APIException.wrap(e, msg: expected_msg)
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
