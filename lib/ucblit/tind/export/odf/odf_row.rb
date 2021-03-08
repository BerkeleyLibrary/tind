require 'rodf'

module UCBLIT
  module TIND
    module Export
      module ODF
        class ODFRow < RODF::Row

          attr_reader :style
          attr_reader :number_rows_repeated
          attr_reader :trailing_blank_cols

          def initialize(number = 0, opts = {})
            super

            number_rows_repeated = opts[:number_rows_repeated] || 1
            @number_rows_repeated = number_rows_repeated if number_rows_repeated

            trailing_blank_cols = opts[:trailing_blank_cols] || 1
            @trailing_blank_cols = trailing_blank_cols if trailing_blank_cols
          end

          def xml
            elem_attrs = {}
            elem_attrs['table:style-name'] = style if style
            elem_attrs['table:number-rows-repeated'] = number_rows_repeated if number_rows_repeated > 1
            Builder::XmlMarkup.new.tag!('table:table-row', elem_attrs) do |xml|
              xml << cells_xml
              xml << ODFCell.repeat(trailing_blank_cols).xml if trailing_blank_cols > 1
            end
          end

          class << self
            def repeat(num_repeated, number:, trailing_blank_cols: 0, row_style: nil)
              opts = {}
              opts[:style] = row_style if row_style
              opts[:number_rows_repeated] = num_repeated if num_repeated > 1
              opts[:trailing_blank_cols] = trailing_blank_cols if trailing_blank_cols > 1
              ODFRow.new(number, opts)
            end
          end
        end
      end
    end
  end
end
