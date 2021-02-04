require 'stringio'

module UCBLIT
  module TIND
    module Util
      module Refinements
        module StringIO
          refine ::StringIO do
            # @param i [Integer] the byte index
            # @return [Integer] the byte at position i
            def [](i)
              return if i > size
              return if size + i < 0

              pos_orig = pos
              begin
                seek(i >= 0 ? i : size + i)
                getbyte
              ensure
                seek(pos_orig)
              end
            end
          end
        end
      end
    end
  end
end
