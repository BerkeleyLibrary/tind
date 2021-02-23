require 'http'
require 'ucblit/tind/config'
require 'ucblit/util/uris'
require 'stringio'

module UCBLIT
  module TIND
    module API
      # The environment variable from which to read the TIND API key.
      ENV_TIND_API_KEY = 'LIT_TIND_API_KEY'.freeze

      class << self
        include UCBLIT::Util
        include UCBLIT::TIND::Config

        # Sets the TIND API key.
        # @param value [String] the API key.
        attr_writer :api_key

        # Gets the TIND API key.
        # @return [String, nil] the TIND API key, or `nil` if not set.
        def api_key
          @api_key ||= ENV[API::ENV_TIND_API_KEY]
        end

        # Gets the API base URI.
        # @return [URI, nil] the API base URI, or `nil` if {UCBLIT::TIND::Config#base_uri} is not set
        def api_base_uri
          return unless base_uri

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
        #   @param endpoint [Symbol, String] the API endpoint, e.g. `:search` or `:collection`
        #   @param **params [Hash] the query parameters
        #   @yieldparam body [IO] the response body, as an IO stream
        def get(endpoint, **params, &block)
          endpoint_url = uri_for(endpoint).to_s
          raise ArgumentError, "No endpoint URL found for #{endpoint.inspect}" if endpoint_url.empty?

          response = do_get(endpoint_url, params)
          return response.body.to_s unless block_given?

          stream_response_body(response.body, &block)
        end

        private

        def do_get(endpoint_url, params)
          logger.info("GET #{endpoint_url}?#{URI.encode_www_form(params)}")
          request = HTTP.follow
          request = request.headers(Authorization: "Token #{api_key}") if api_key
          request.get(endpoint_url, params: params).tap do |response|
            status = response.status
            logger.info("GET #{endpoint_url} returned #{status}")
            raise(HTTP::ResponseError, status.to_s) unless status.success?
          end
        end

        def stream_response_body(body)
          IO.pipe do |rd, wr|
            Thread.new do
              body.each { |chunk| wr.write(chunk) }
              wr.close
              Thread.exit
            end

            yield rd
          end
        end
      end
    end
  end
end
