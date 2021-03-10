require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TableColumnProperties < ElementNode
            attr_reader :width

            def initialize(width, doc:)
              super(:table, 'table-column-properties', doc: doc)
              @width = width
              add_default_attributes!
            end

            private

            def add_default_attributes!
              add_attribute(:fo, 'break-before', 'auto')
              add_attribute('column-width', width)
            end
          end
        end
      end
    end
  end
end
