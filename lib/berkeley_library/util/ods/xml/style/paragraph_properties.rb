require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class ParagraphProperties < ElementNode

            DEFAULT_TAB_STOP_DISTANCE = '0.5in'.freeze

            attr_reader :tab_stop_distance

            def initialize(tab_stop_distance = DEFAULT_TAB_STOP_DISTANCE, doc:)
              super(:style, 'paragraph-properties', doc: doc)
              @tab_stop_distance = tab_stop_distance
              set_default_attributes!
            end

            private

            def set_default_attributes!
              set_attribute('tab-stop-distance', tab_stop_distance)
            end
          end
        end
      end
    end
  end
end
