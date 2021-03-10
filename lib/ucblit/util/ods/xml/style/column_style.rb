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

            def initialize(name, width = nil, doc:)
              super(name, :table_column, doc: doc)
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
