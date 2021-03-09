require 'ucblit/util/ods/xml_element'

module UCBLIT
  module Util
    module ODS
      class Scripts < XMLElement
        def initialize(doc:)
          super(:office, 'scripts', doc: doc)
        end
      end
    end
  end
end
