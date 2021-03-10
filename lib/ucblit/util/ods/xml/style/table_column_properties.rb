require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TableRowProperties < ElementNode
            attr_reader :height

            def initialize(height, doc:)
              super(:table, 'table-row-properties', doc: doc)
              @height = height

              add_default_attributes!
            end

            private

            def add_default_attributes!
              add_attribute('row-height', height)
              add_attribute(:fo, 'break-before', 'auto')
              add_attribute('use-optimal-row-height', 'true')
            end
          end
        end
      end
    end
  end
end
