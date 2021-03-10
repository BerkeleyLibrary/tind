require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module LOExt
          class TableProtection < ElementNode
            def initialize(doc:)
              super(:loext, 'table-protection', doc: doc)

              add_default_attributes!
            end

            private

            def add_default_attributes!
              add_attribute('select-protected-cells', 'true')
              add_attribute('select-unprotected-cells', 'true')
            end
          end
        end
      end
    end
  end
end
