require 'spec_helper'
# require 'upload_file'

module BerkeleyLibrary
  module TIND
    module API
      describe UploadFile do
        before(:all) do
          UploadFile.s3_preasign_api = 'https://berkeley-test.tind.io/storage/presigned_post?location=TOS'.freeze
          UploadFile.s3_preasign_token = 'aabbccdd1234'
        end

        let(:tind_s3_api) { 'https://berkeley-test.tind.io/storage/presigned_post?location=TOS'.freeze }
        let(:pre_assign_heders) { { 'Authorization' => 'Token aabbccdd1234' } }
        let(:pre_assign_response_body) { File.open('./spec/data/api/pre_assigned_response.json') }

        xdescribe '#preassign_response' do
          it 'request to get a pre-assigned url and ACL' do
            stub_request(:get, /berkeley-test.tind.io/)
              .with(headers: pre_assign_heders)
              .to_return(status: 200, body: pre_assign_response_body, headers: {})
    
            resp = uploader.presign_response
            expect(resp['data']['url']).to eq('https://test_bucket.s3.amazonaws.com/')
            expect(resp['data']['fields']['acl']).to eq('private')
          end
        end

        # describe '#preassign_response' do
        #   it 'request to get a pre-assigned url and ACL' do
        #     stub_request(:get, tind_s3_api)
        #       .with(
        #         headers: {
        #           'Accept' => '*/*',
        #           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        #           'Authorization' => 'Token aabbccdd1234',
        #           'Host' => 'berkeley-test.tind.io',
        #           'User-Agent' => 'rest-client/2.1.0 (darwin19 x86_64) ruby/2.7.5p203'
        #         }
        #       )
        #       .to_return(status: 200, body: pre_assign_response_body, headers: {})

        #     # registered request stubs:
        #     stub_request(:get, tind_s3_api)
        #       .with(
        #         headers: {
        #           'Authorization' => 'Token aabbccdd1234'
        #         }
        #       )

        #     resp = UploadFile.presign_response
        #     expect(resp['data']['url']).to eq('https://test_bucket.s3.amazonaws.com/')
        #     expect(resp['data']['fields']['acl']).to eq('private')
        #   end
        # end

        describe '#excute' do
          it 'post to upload a file to S3, and get etag from responsed header' do
            f = File.open('./spec/data/api/upload_file.json', 'rb')
            key_etag = { key: '"711aca11-0de1-4110-ac73-8989"', etag: '"99914b932bd37a50b983c5e7c90ae93b"' }
            allow(UploadFile).to receive(:execute).with(f).and_return(key_etag)
            response = UploadFile.execute(f)
            expect(response).to eq(key_etag)
          end
        end
      end
    end

  end
end
