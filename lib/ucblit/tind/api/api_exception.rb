module UCBLIT
  module TIND
    module API
      # Wrapper for network-related exceptions.
      class APIException < StandardError
        attr_reader :status_code, :status_message, :response

        def initialize(msg, status_code: nil, status_message: nil, response: nil)
          super(msg)

          @status_code = status_code
          @status_message = status_message
          @response = response
        end

        def body
          return @body if instance_variable_defined?(:@body)

          @body = response && response.body
        end

        class << self
          def wrap(ex, msg: nil)
            raise ArgumentError, "Can't wrap a nil error" unless ex

            params = {}.tap do |p|
              next unless [:http_code, :message, :response].all? { |f| ex.respond_to?(f) }

              p[:status_code] = ex.http_code
              p[:status_message] = ex.message
              p[:response] = ex.response
            end

            return APIException.new(msg || ex.to_s, **params)
          end
        end
      end
    end
  end
end
