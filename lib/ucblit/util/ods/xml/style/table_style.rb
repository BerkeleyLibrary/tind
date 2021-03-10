require 'ucblit/util/ods/xml/style/style'
require 'ucblit/util/ods/xml/style/family'
require 'ucblit/util/ods/xml/style/table_properties'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TableStyle < Style
            # Initializes a new table style. Note that this should not be called
            # directly, but only from {XML::Office::AutomaticStyles#add_table_style}.
            #
            # @param name [String] the name of the style
            # @param styles [XML::Office::AutomaticStyles] the document styles
            def initialize(name, styles:)
              super(name, :table, doc: styles.doc)

              set_attribute('master-page-name', 'Default')
              children << TableProperties.new(doc: doc)
            end
          end
        end
      end
    end
  end
end
