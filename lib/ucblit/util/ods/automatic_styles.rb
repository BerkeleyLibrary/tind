require 'ucblit/util/ods/xml_element'
module UCBLIT
  module Util
    module ODS
      class AutomaticStyles < XMLElement
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
