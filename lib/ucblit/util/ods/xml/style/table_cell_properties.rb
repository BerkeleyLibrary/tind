require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TableCellProperties < ElementNode

            def initialize(protected, doc:)
              super(:table, 'table-cell-properties', doc: doc)
              @protected = protected
              add_default_attributes!
            end

            def protected?
              @protected
            end

            private

            def add_default_attributes!
              add_attribute('cell-protect', protected? ? 'protected' : 'none')
              add_attribute('print-content', 'true')
            end
          end
        end
      end
    end
  end
end
