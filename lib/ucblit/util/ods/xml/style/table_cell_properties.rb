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
              set_default_attributes!
            end

            def protected?
              @protected
            end

            private

            def set_default_attributes!
              set_attribute('cell-protect', protected? ? 'protected' : 'none')
              set_attribute('print-content', 'true')
            end
          end
        end
      end
    end
  end
end
