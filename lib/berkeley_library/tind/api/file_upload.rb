require 'spec_helper'
require 'webmock'

module BerkeleyLibrary
  module TIND
    module API

      class FileUpload
        include BerkeleyLibrary::Logging

        def initialize(url, token)
          @url = url
          @headers = pre_assigned_headers(token)
        end

        # def execute(file)
        #   hash = pre_assigned_hash
        #   hash ? upload(file, hash) : nil
        #   # rescue StandardError => e
        #   #   raise " uploading '#{file}' failed: #{e.message} "
        #   # ensure
        #   #   nil
        # end

        def execute(file)
          pre_response = pre_assigned_response
          hash = pre_assigned_hash(pre_response)

          upload_response = upload(file, hash)
          fft_params(upload_response, hash, file)
        end

        private

        # def pre_assigned_hash
        #   response = RestClient::Request.execute(
        #     method: :get,
        #     url: @url,
        #     headers: @headers
        #   )
        #   success?(response, 200) ? JSON.parse(response) : nil
        # rescue StandardError => e
        #   logger.error(e)
        #   raise
        # end

        def pre_assigned_response
          RestClient::Request.execute(
            method: :get,
            url: @url,
            headers: @headers
          )
        rescue StandardError => e
          logger.error(e)
          raise
        end

        def pre_assigned_hash(response)
          success?(response, 200) ? JSON.parse(response) : nil
        end

        # def upload(file, hash)
        #   response = File.open(file, 'rb') do |f|
        #     RestClient::Request.execute(
        #       method: :post,
        #       url: upload_url(hash),
        #       headers: upload_headers(hash),
        #       payload: fields(hash).merge(file: f)
        #     )
        #   end
        #   fft_params(response, hash)
        # rescue StandardError => e
        #   logger.error(e)
        #   nil
        # end

        def upload(file, hash)
          File.open(file, 'rb') do |f|
            RestClient::Request.execute(method: :post, url: upload_url(hash), headers: upload_headers(hash), payload: fields(hash).merge(file: f))
          end
        rescue StandardError => e
          txt = " Failed in uploading '#{file}': #{e.message} "
          logger.error(txt)
          nil
        end

        def success?(response, expected_code, file = nil)
          code = response.code

          return true if  code == expected_code

          raise_error(code, file)

          false
        end

        def raise_error(code, file)
          val = code.to_s
          first_chr = val[0]
          case first_chr
          when first_chr == '4' then  raise 'Client side error'
          when first_chr == '5' then  raise 'Server side error'
          else
            raise " Error: RestClient response code = #{val}" unless file

            txt = " Failed in uploading '#{file}': RestClient response code = #{val}"
            logger.error(txt)
          end
        end

        def fft_params(response, hash, file)
          return nil unless success?(response, 204, file) # success but no content

          logger.message(" File '#{file}' has been successfully uploaded.  ")

          { object_id: obj_key(hash), etag: obj_etag(response) }
        end

        def pre_assigned_headers(token)
          str = "Token #{token}"
          { 'Authorization' => str }
        end

        def fields(hash)
          hash['data']['fields']
        end

        def obj_key(hash)
          fields(hash)['key']
        end

        def obj_etag(response)
          response.headers[:etag].delete('\"')
        end

        def upload_url(hash)
          hash['data']['url']
        end

        def upload_headers(hash)
          val = fields(hash)['acl']
          { 'x-amz-acl' => val }
        end

      end

    end
  end
end
