require 'ucblit/util/ods/xml/table/repeatable'
require 'ucblit/util/ods/xml/text/p'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          class TableCell < Repeatable
            attr_reader :value
            attr_reader :cell_style

            def initialize(value = nil, cell_style = nil, number_repeated = 1, table:)
              super('table-cell', 'number-columns-repeated', number_repeated, table: table)

              @value = value
              @cell_style = cell_style

              set_default_attributes!
              add_default_children!
            end

            class << self
              def repeat_empty(number_repeated, cell_style = nil, table:)
                TableCell.new(nil, cell_style, number_repeated, table: table)
              end
            end

            private

            def set_default_attributes!
              set_attribute('style-name', cell_style.style_name) if cell_style
              set_attribute(:office, 'value-type', 'string') if value
              set_attribute(:calcext, 'value-type', 'string') if value
            end

            def add_default_children!
              children << XML::Text::P.new(value, doc: doc) if value
            end

          end
        end
      end
    end
  end
end
