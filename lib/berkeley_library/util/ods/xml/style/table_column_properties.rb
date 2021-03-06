require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class TableRowProperties < ElementNode
            attr_reader :height

            def initialize(height, doc:)
              super(:style, 'table-row-properties', doc: doc)
              @height = height

              set_default_attributes!
            end

            private

            def set_default_attributes!
              set_attribute('row-height', height)
              set_attribute(:fo, 'break-before', 'auto')
              set_attribute('use-optimal-row-height', 'true')
            end
          end
        end
      end
    end
  end
end
