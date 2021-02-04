require 'http'
require 'ucblit/tind/config'
require 'ucblit/util/uris'

module UCBLIT
  module TIND
    module API

      def get(endpoint, **params)
        API.get(endpoint, **params)
      end

      class << self
        include UCBLIT::Util
        include UCBLIT::TIND::Config

        ENV_TIND_API_KEY = 'LIT_TIND_API_KEY'.freeze

        def api_key
          @api_key ||= ENV[ENV_TIND_API_KEY]
        end

        attr_writer :api_key

        def api_base_uri
          return unless base_uri

          URIs.append(base_uri, '/api/v1')
        end

        def uri_for(endpoint)
          return unless api_base_uri

          URIs.append(api_base_uri, endpoint)
        end

        def get(endpoint, **params)
          endpoint_url = uri_for(endpoint).to_s
          raise ArgumentError, "No endpoint URL found for #{endpoint.inspect}" if endpoint_url.empty?

          resp = HTTP.follow
            .headers(Authorization: "Token #{api_key}")
            .get(endpoint_url, params: params)

          resp.status.tap do |status|
            next if status.success?

            raise HTTP::ResponseError, status.to_s
          end

          # TODO: convert body to something IO-like?
          resp.body.to_s
        end
      end
    end
  end
end
