require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Office
          class Scripts < XML::ElementNode
            def initialize(doc:)
              super(:office, 'scripts', doc: doc)
            end
          end
        end
      end
    end
  end
end
