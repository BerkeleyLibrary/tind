require 'ucblit/util/ods/xml/style/style'
require 'ucblit/util/ods/xml/style/table_column_properties'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class ColumnStyle < Style
            DEFAULT_WIDTH = '1in'.freeze

            attr_reader :width

            # Initializes a new column style. Note that this should not be called
            # directly, but only from {XML::Office::AutomaticStyles#add_column_style}.
            #
            # @param style_name [String] the name of the style
            # @param width [String] the column width
            # @param styles [XML::Office::AutomaticStyles] the document styles
            def initialize(style_name, width = nil, styles:)
              super(style_name, :table_column, doc: styles.doc)
              @width = width || DEFAULT_WIDTH
              add_default_children!
            end

            private

            def add_default_children!
              children << TableColumnProperties.new(width, doc: doc)
            end
          end
        end
      end
    end
  end
end
