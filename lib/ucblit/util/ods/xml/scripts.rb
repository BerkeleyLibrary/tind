require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        class Scripts < ElementNode
          def initialize(doc:)
            super(:office, 'scripts', doc: doc)
          end
        end
      end
    end
  end
end
