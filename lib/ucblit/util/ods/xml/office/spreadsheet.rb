require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class Spreadsheet < XML::ElementNode
            def initialize(doc:)
              super(:office, 'spreadsheet', doc: doc)
            end
          end
        end
      end
    end
  end
end
