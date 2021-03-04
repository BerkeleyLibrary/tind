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

      def diff_index(s1, s2)
        s1.chars.each_with_index do |c, i|
          return i if c != s2[i]
        end
        s2.length if s2.length > s1.length
      end

      class << self
        include Strings
      end
    end
  end
end
