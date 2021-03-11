require 'ucblit/logging'

module UCBLIT
  module Util
    # TODO: move this to ucblit-logging
    module Logging
      def logger
        UCBLIT::Util::Logging.logger
      end

      def logger=(v)
        UCBLIT::Util::Logging.logger = v
      end

      class << self
        def logger
          @logger ||= UCBLIT::Logging::Loggers.default_logger
        end

        attr_writer :logger
      end
    end
  end
end
