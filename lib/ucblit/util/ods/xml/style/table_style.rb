require 'ucblit/util/ods/xml/style/style'
require 'ucblit/util/ods/xml/style/family'
require 'ucblit/util/ods/xml/style/table_properties'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TableStyle < Style
            def initialize(name, doc:)
              super(name, :table, doc: doc)

              add_attribute('master-page-name', 'Default')
              children << TableProperties.new(doc: doc)
            end
          end
        end
      end
    end
  end
end
