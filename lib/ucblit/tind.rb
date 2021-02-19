require 'marc_extensions'
require 'ucblit/logging'

Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))

module UCBLIT
  module TIND
    class << self
      def logger
        @logger ||= UCBLIT::Logging::Loggers.default_logger
      end

      attr_writer :logger
    end
  end
end
