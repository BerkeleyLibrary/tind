module UCBLIT
  module Util
    module Strings

      ASCII_0 = '0'.ord
      ASCII_9 = '9'.ord

      def ascii_numeric?(s)
        s.chars.all? do |c|
          ord = c.ord
          ord >= ASCII_0 && ord <= ASCII_9
        end
      end

      class << self
        include Strings
      end
    end
  end
end
