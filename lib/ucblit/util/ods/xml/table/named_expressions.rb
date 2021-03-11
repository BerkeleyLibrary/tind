require 'ucblit/util/ods/xml/element_node'

module UCBLIT
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
