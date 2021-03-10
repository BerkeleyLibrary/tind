require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TableProperties < ElementNode
            def initialize(doc:)
              super(:table, 'table-properties', doc: doc)
              set_default_attributes!
            end

            private

            def set_default_attributes!
              set_attribute('display', 'true')
              set_attribute('writing-mode', 'lr-tb')
            end
          end
        end
      end
    end
  end
end
