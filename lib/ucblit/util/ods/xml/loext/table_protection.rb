require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module LOExt
          class TableProtection < ElementNode
            def initialize(doc:)
              super(:loext, 'table-protection', doc: doc)

              set_default_attributes!
            end

            private

            def set_default_attributes!
              set_attribute('select-protected-cells', 'true')
              set_attribute('select-unprotected-cells', 'true')
            end
          end
        end
      end
    end
  end
end
