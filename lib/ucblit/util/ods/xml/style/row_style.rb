require 'ucblit/util/ods/xml/style/style'
require 'ucblit/util/ods/xml/style/table_row_properties'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class RowStyle < Style

            DEFAULT_HEIGHT = '0.25in'.freeze

            attr_reader :height

            def initialize(name, height = nil, doc:)
              super(name, :table_row, doc: doc)
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
