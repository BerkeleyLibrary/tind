require 'rodf'

module UCBLIT
  module TIND
    module Export
      module ODF
        class ODFCell < RODF::Cell
          def initialize(value = nil, opts = {})
            super

            number_columns_repeated = opts[:number_columns_repeated]
            @elem_attrs['table:number-columns-repeated'] = number_columns_repeated if number_columns_repeated
          end

          class << self
            def repeat(num_repeats, value: nil)
              ODFCell.new(value, number_columns_repeated: num_repeats)
            end
          end
        end
      end
    end
  end
end
