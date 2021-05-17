require 'net/http/status'

module UCBLIT
  module TIND
    module API
      # Wrapper for network-related exceptions.
      class APIException < StandardError
        # @return [String, nil] the request URI, if any
        attr_reader :url

        # @return [Hash, nil] the API query parameters, if any
        attr_reader :params

        # @return [Integer, nil] the numeric HTTP status code, if any
        attr_reader :status_code

        # @return [String, nil] the HTTP status message, if any
        attr_reader :status_message

        # @return [RestClient::Response, nil] the response, if any
        attr_reader :response

        # Initializes a new APIException.
        #
        # @option opts [String] :msg the exception message (if not present, a default message will be constructed)
        # @option opts [String] :url the request URL, if any
        # @option opts [Hash] :params the query or form parameters, if any
        # @option opts [Integer] :status_code the numeric HTTP status code, if any
        # @option opts [String] :status_message a human-readable string representation of the HTTP status
        #   (if not present, a default will be constructed)
        # @option opts [RestClient::Response] :response the HTTP response, if any
        def initialize(msg, **opts)
          super(msg)

          @url = opts[:url].to_s if opts.key?(:url)
          @params = opts[:params]
          @status_code, default_status_message = format_status(opts[:status_code])
          @status_message = opts[:status_message] || default_status_message
          @response = opts[:response]
        end

        def body
          return @body if instance_variable_defined?(:@body)

          @body = response && response.body
        end

        private

        def format_status(status_code)
          return unless (numeric_status = Integer(status_code, exception: false))

          status_name = Net::HTTP::STATUS_CODES[numeric_status]
          default_status_message = [numeric_status, status_name].compact.join(' ')

          [numeric_status, default_status_message]
        end

        class << self
          # @param ex [Exception] the exception to wrap
          # @option opts [String] :msg the exception message (if not present, a default message will be constructed)
          # @option opts [String] :url the request URL, if any
          # @option opts [Hash] :params the query or form parameters, if any
          # @option opts [String] :msg_context context information to prepend to the default message
          def wrap(ex, **opts)
            raise ArgumentError, "Can't wrap a nil error" unless ex

            msg = opts[:msg] || message_from(ex, opts[:url], opts[:params], opts[:detail])
            options = format_options(ex, opts[:url], opts[:params])
            APIException.new(msg, **options)
          end

          private

          def format_options(ex, url, params)
            {}.tap do |opts|
              opts[:url] = url if url
              opts[:params] = params if params
              next unless %i[http_code message response].all? { |f| ex.respond_to?(f) }

              opts[:status_code] = ex.http_code
              opts[:status_message] = ex.message
              opts[:response] = ex.response
            end
          end

          def message_from(ex, url, params, detail)
            ''.tap do |msg|
              msg << "#{detail}: " if detail
              msg << (url ? "#{API.format_request(url, params)} returned #{ex}" : ex.to_s)
            end
          end
        end
      end

      # Exception raised when the API key is nil or blank.
      #
      # NOTE: TIND incorrectly returns 403 Forbidden in this case, but we don't even bother
      # to ask, we just simulate a 401.
      class APIKeyNotSet < APIException
        # @param endpoint_uri [URI] the endpoint URI
        # @param params [Hash, nil] the query parameters
        def initialize(endpoint_uri, params)
          request_str = API.format_request(endpoint_uri, params)
          super("#{request_str} failed; API key not set", status_code: 401)
        end
      end

      # Exception raised when the TIND base URI is nil or blank.
      class BaseURINotSet < APIException
        # @param endpoint [String, Symbol] the endpoint
        # @param params [Hash, nil] the query parameters
        def initialize(endpoint, params)
          msg = BaseURINotSet.format_message(endpoint, params)
          super(msg, status_code: 404)
        end

        class << self
          def format_message(endpoint, params)
            "request to endpoint #{endpoint.inspect}".tap do |msg|
              if (query_string = API.format_query(params))
                msg << " with query #{query_string}"
              end
              msg << ' failed; base URI not set'
            end
          end
        end
      end
    end
  end
end
