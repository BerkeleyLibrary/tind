require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TableProperties < ElementNode
            def initialize(doc:)
              super(:table, 'table-properties', doc: doc)
              add_default_attributes!
            end

            private

            def add_default_attributes!
              add_attribute('display', 'true')
              add_attribute('writing-mode', 'lr-tb')
            end
          end
        end
      end
    end
  end
end
