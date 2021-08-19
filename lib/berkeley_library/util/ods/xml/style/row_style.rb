require 'berkeley_library/util/ods/xml/style/style'
require 'berkeley_library/util/ods/xml/style/table_row_properties'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class RowStyle < Style

            DEFAULT_HEIGHT = '0.25in'.freeze

            attr_reader :height

            # Initializes a new cell style. Note that this should not be called
            # directly, but only from {XML::Office::AutomaticStyles#add_row_style}.
            #
            # @param name [String] the name of the style
            # @param height [String] the row height
            # @param styles [XML::Office::AutomaticStyles] the document styles
            def initialize(name, height = nil, styles:)
              super(name, :table_row, doc: styles.doc)
              @height = height || DEFAULT_HEIGHT
              add_default_children!
            end

            private

            def add_default_children!
              children << TableRowProperties.new(height, doc: doc)
            end
          end
        end
      end
    end
  end
end
