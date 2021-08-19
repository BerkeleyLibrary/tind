require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
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
