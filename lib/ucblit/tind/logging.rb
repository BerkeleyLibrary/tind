module UCBLIT
  module TIND
    module Logging
      def logger
        UCBLIT::TIND.logger
      end

      class << self
        include Logging
      end
    end
  end
end
