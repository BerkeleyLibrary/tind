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
        return unless [s1, s2].all? { |s| s.respond_to?(:chars) && s.respond_to?(:length) }

        # TODO: determine shorter & iterate that first
        s1.chars.each_with_index do |c, i|
          return i if c != s2[i]
        end
        s1.length if s2.length > s1.length
      end

      class << self
        include Strings
      end
    end
  end
end
