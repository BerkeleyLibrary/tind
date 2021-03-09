require 'ucblit/util/ods/xml/element_node'
module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class AutomaticStyles < XML::ElementNode
            def initialize(doc:)
              super(:office, 'automatic-styles', doc: doc)
            end

            def add_style(style)
              children << style
            end
          end
        end
      end
    end
  end
end
