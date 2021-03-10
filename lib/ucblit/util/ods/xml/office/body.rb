require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class Body < XML::ElementNode
            def initialize(doc:)
              super(:office, 'body', doc: doc)
            end
          end
        end
      end
    end
  end
end
