require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Table
          class NamedExpressions < XML::ElementNode
            def initialize(doc:)
              super(:table, 'named-expressions', doc: doc)
            end
          end
        end
      end
    end
  end
end
