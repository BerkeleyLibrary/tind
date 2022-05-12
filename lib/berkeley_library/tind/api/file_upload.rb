require 'berkeley_library/logging'
require 'rest-client'
require 'json'

module BerkeleyLibrary
  module TIND
    module API
      class FileUpload
        include BerkeleyLibrary::Logging

        def initialize(url, token)
          @url = url
          @headers = pre_assigned_headers(token)
        end

        def execute(file)
          hash = pre_assigned_hash
          hash ? upload(file, hash) : nil
        rescue StandardError => e
          raise "'#{file}' uploading failed - #{e.message} "
        ensure
          nil
        end

        private

        def pre_assigned_hash
          response = RestClient::Request.execute(
            method: :get,
            url: @url,
            headers: @headers
          )
          success?(response) ? JSON.parse(response) : nil
        end

        def upload(file, hash)
          response = File.open(file, 'rb') do |f|
            RestClient::Request.execute(
              method: :post,
              url: upload_url(hash),
              headers: upload_headers(hash),
              payload: fields(hash).merge(file: f)
            )
          end

          fft_params(response, hash)
        end

        def success?(response)
          return true if response.status.success? # 3XX

          raise 'Client side error' if response.status.client_error? # 4XX
          raise 'Server side error' if response.status.server_error? # 5XX

          false
        end

        def fft_params(response, hash)
          return nil unless success?(response)

          { object_id: obj_key(hash), etag: response.headers[:etag] }
        end

        def pre_assigned_headers(token)
          str = "'Token #{token}'"
          { 'Authorization' => str }
        end

        def fields(hash)
          hash['data']['fields']
        end

        def obj_key(hash)
          fields(hash)['key']
        end

        def upload_url(hash)
          hash['data']['url']
        end

        def upload_headers(hash)
          val = fields(hash)['acl']
          { 'x-amz-acl' => "'#{val}'" }
        end

      end
    end
  end
end
