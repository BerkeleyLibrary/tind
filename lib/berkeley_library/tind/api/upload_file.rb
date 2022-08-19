require 'rest-client'
require 'json'

module BerkeleyLibrary
  module TIND
    module API
      module UploadFile
        include BerkeleyLibrary::Logging

        @s3_preasign_api = ''
        @s3_preasign_token = ''

        class << self
          attr_accessor :s3_preasign_api
          attr_accessor :s3_preasign_token

          include UploadFile
        end

        def execute(file)
          hash = presign_response
          response = file_uploaded_response(file, hash)
          return key_etag(response, hash, file) if success?(response, 204, file)

          raise failed_response(file)
        end

        def presign_response
          txt = failed_response
          with_rescue(txt) do
            response = RestClient::Request.execute(
              method: :get,
              url: @s3_preasign_api,
              headers: preasign_headers
            )
            puts response
            return JSON.parse(response) if success?(response, 200)

            raise failed_response
          end
        end

        def file_uploaded_response(file, hash)
          txt = failed_response(file)
          with_rescue(txt) do
            File.open(file, 'rb') do |f|
              RestClient::Request.execute(method: :post, url: upload_url(hash), headers: upload_headers(hash),
                                          payload: fields(hash).merge(file: f))
            end
          end
        end

        private

        def success?(response, expected_code, file = nil)
          code = response.code

          return true if  code == expected_code

          logging_error_code(code, file)

          false
        end

        def key_etag(response, hash, file)
          logger.info("'#{file}' uploaded successfully.  ")  # question: should log this?

          { key: obj_key(hash), etag: obj_etag(response) }
        end

        def preasign_headers
          str = "Token #{@s3_preasign_token}"
          { 'Authorization' => str }
        end

        def logging_error_code(code, file)
          txt = failed_response(file)
          val = code.to_s
          first_chr = val[0]
          case first_chr
          when first_chr == '4' then  logger.error("#{txt} - Client side")
          when first_chr == '5' then  logger.error("#{txt} - Server side")
          else
            logger.error("#{txt}, code = #{val}")
          end
        end

        def with_rescue(txt)
          yield
        rescue StandardError => e
          logger.error("#{txt} : #{e.message}")
          raise
        end
    

        def failed_response(file = nil)
          file ? "Failed in uploading '#{file}'  " : 'Failed in S3 API Preasign '
        end

      end
    end

  end
end
