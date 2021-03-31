require 'stringio'
require 'open-uri'

require 'ucblit/util/uris'
require 'ucblit/tind/config'
require 'ucblit/util/logging'
require 'ucblit/tind/api/api_exception'

module UCBLIT
  module TIND
    module API
      class << self
        include UCBLIT::Util
        include UCBLIT::Util::Logging

        # Gets the TIND API key.
        # @return [String, nil] the TIND API key, or `nil` if not set.
        def api_key
          UCBLIT::TIND::Config.api_key
        end

        # Gets the API base URI.
        # @return [URI, nil] the API base URI, or `nil` if {UCBLIT::TIND::Config#base_uri} is not set
        def api_base_uri
          return unless (base_uri = Config.base_uri)

          URIs.append(base_uri, '/api/v1')
        end

        # Gets the URI for the specified API endpoint.
        # @param endpoint [Symbol, String] the endpoint (e.g. `:search` or `:collection`)
        # @return [URI, nil] the URI for the specified endpoint, or `nil` if {UCBLIT::TIND::Config#base_uri} is not set
        def uri_for(endpoint)
          return unless api_base_uri

          URIs.append(api_base_uri, endpoint)
        end

        # Makes a GET request.
        #
        # @overload get(endpoint, **params)
        #   Makes a GET request to the specified endpoint with the specified parameters,
        #   and returns the response body as a string. Example:
        #
        #   ```ruby
        #   marc_xml = API.get(:search, c: 'The Bancroft Library')
        #   XMLReader.new(marc_xml).each { |record| ... }
        #   ```
        #
        #   @param endpoint [Symbol] the API endpoint, e.g. `:search` or `:collection`
        #   @param **params [Hash] the query parameters
        # @overload get(endpoint, **params, &block)
        #   Makes a GET request to the specified endpoint with the specified parameters,
        #   and yields an `IO` that streams the response body. Example:
        #
        #   ```ruby
        #   API.get(:search, c: 'The Bancroft Library') do |body|
        #     XMLReader.new(body).each { |record| ... }
        #   end
        #   ```
        #
        #   @param endpoint [Symbol, String] the API endpoint, e.g. `:search` or `:collections`
        #   @param **params [Hash] the query parameters
        #   @yieldparam body [IO] the response body, as an IO stream
        def get(endpoint, **params, &block)
          endpoint_url = uri_for(endpoint).to_s
          raise ArgumentError, "No endpoint URL found for #{endpoint.inspect}; #{Config::ENV_TIND_BASE_URL} not set?" if endpoint_url.empty?

          logger.debug("GET #{debug_uri(endpoint_url, params)}")
          # logger.debug("Headers", headers)
          body = URIs.get(endpoint_url, params, headers)
          return body unless block_given?

          stream_response_body(body, &block)
        rescue RestClient::RequestFailed => e
          raise APIException, e.message
        end

        private

        def headers
          {}.tap do |headers|
            headers['Authorization'] = "Token #{api_key}" if api_key
          end
        end

        def debug_uri(url, params)
          URIs.append(url, "?#{URI.encode_www_form(params)}")
        end

        # TODO: make real body streaming work
        def stream_response_body(body)
          yield StringIO.new(body)
        rescue StandardError => e
          # We don't log the full stack trace here as we assume the block will do that
          logger.warn("Error yielding response body: #{e}: body was: #{body}")
          raise
        end
      end

    end
  end
end
