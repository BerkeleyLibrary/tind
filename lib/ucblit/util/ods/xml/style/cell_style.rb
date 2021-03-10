require 'ucblit/util/ods/xml/style/style'
require 'ucblit/util/ods/xml/style/table_cell_properties'
require 'ucblit/util/ods/xml/style/text_properties'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class CellStyle < Style
            # rubocop:disable Style/OptionalBooleanParameter
            def initialize(name, protected = false, color = nil, doc:)
              super(name, :table_cell, doc: doc)
              @protected = protected
              @color = color
              add_default_children!
            end
            # rubocop:enable Style/OptionalBooleanParameter

            def protected?
              @protected
            end

            private

            def add_default_children!
              children << TableCellProperties.new(protected?, doc: doc)
              children << TextProperties.new(color, doc: doc) if color
            end
          end
        end
      end
    end
  end
end
