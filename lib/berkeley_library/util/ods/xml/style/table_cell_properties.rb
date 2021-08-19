require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class TableCellProperties < ElementNode

            # rubocop:disable Style/KeywordParametersOrder
            def initialize(protected, wrap: false, doc:)
              super(:style, 'table-cell-properties', doc: doc)
              @protected = protected
              @wrap = wrap
              set_default_attributes!
            end
            # rubocop:enable Style/KeywordParametersOrder

            def protected?
              @protected
            end

            def wrap?
              @wrap
            end

            private

            def set_default_attributes!
              set_attribute(:style, 'cell-protect', protected? ? 'protected' : 'none')
              set_attribute(:style, 'vertical-align', 'top')
              set_attribute('print-content', 'true')
              set_attribute(:fo, 'wrap-option', 'wrap') if wrap?
            end
          end
        end
      end
    end
  end
end
