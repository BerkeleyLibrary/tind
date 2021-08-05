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
        include UCBLIT::Logging

        # Gets the TIND API key.
        # @return [String, nil] the TIND API key, or `nil` if not set.
        def api_key
          UCBLIT::TIND::Config.api_key
        end

        # Gets the value to send in the User-Agent header
        # @return [String] the user agent
        def user_agent
          UCBLIT::TIND::Config.user_agent
        end

        # Gets the API base URI.
        # @return [URI] the API base URI
        def api_base_uri
          return if Config.blank?((base_uri = Config.base_uri))

          URIs.append(base_uri, '/api/v1')
        end

        # Gets the URI for the specified API endpoint.
        # @param endpoint [Symbol, String] the endpoint (e.g. `:search` or `:collection`)
        # @return [URI] the URI for the specified endpoint
        # @raise [API::BaseURINotSet] if the TIND base URI is not set
        def uri_for(endpoint)
          return if Config.blank?(api_base_uri)

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
        #   @return [String] the response body
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
          endpoint_uri = uri_for(endpoint)
          raise BaseURINotSet.new(endpoint, params) if Config.blank?(endpoint_uri)

          logger.debug(format_request(endpoint_uri, params))

          body = do_get(endpoint_uri, params)
          return body unless block_given?

          stream_response_body(body, &block)
        end

        # Returns a formatted string version of the request, suitable for
        # logging or error messages.
        #
        # @param uri [URI, String] the URI
        # @param params [Hash, nil] the query parameters
        # @param method [String] the request method
        def format_request(uri, params = nil, method = 'GET')
          query_string = format_query(params)
          uri = URIs.append(uri, '?', query_string) if query_string

          "#{method} #{uri}"
        end

        def format_query(params)
          return unless params
          return URI.encode_www_form(params.to_hash) if params.respond_to?(:to_hash)

          raise ArgumentError, "Argument #{params.inspect} does not appear to be a set of query parameters"
        end

        private

        def do_get(endpoint_uri, params)
          raise APIKeyNotSet.new(endpoint_uri, params) if Config.blank?(api_key)

          begin
            URIs.get(endpoint_uri, params, {
                       'Authorization' => "Token #{api_key}",
                       'User-Agent' => user_agent
                     })
          rescue RestClient::RequestFailed => e
            raise APIException.wrap(e, url: endpoint_uri, params: params)
          end
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
