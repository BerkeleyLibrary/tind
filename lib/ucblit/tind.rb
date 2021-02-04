require 'marc_extensions'
require 'ucblit/logging'

Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))

module UCBLIT
  module TIND
    class << self
      def logger
        UCBLIT::Logging::Loggers.default_logger
      end
    end
  end
end
