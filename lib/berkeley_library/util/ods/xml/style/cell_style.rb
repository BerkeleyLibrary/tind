require 'berkeley_library/util/ods/xml/style/style'
require 'berkeley_library/util/ods/xml/style/table_cell_properties'
require 'berkeley_library/util/ods/xml/style/text_properties'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class CellStyle < Style

            attr_reader :color, :font_weight

            # Initializes a new cell style. Note that this should not be called
            # directly, but only from {XML::Office::AutomaticStyles#add_cell_style}.
            #
            # @param name [String] the style name
            # @param color [String, nil] a hex color (e.g. `#fdb515`)
            # @param font_weight [String, nil] the font weight, if other than normal
            # @param wrap [Boolean] whether to allow text wrapping
            # @param styles [XML::Office::AutomaticStyles] the document styles
            # rubocop:disable Metrics/ParameterLists, Style/OptionalBooleanParameter
            def initialize(name, protected = false, color = nil, styles:, font_weight: nil, wrap: false)
              super(name, :table_cell, doc: styles.doc)
              @protected = protected
              @color = color
              @font_weight = font_weight
              @wrap = wrap

              set_attribute('parent-style-name', 'Default')
              add_default_children!
            end
            # rubocop:enable Metrics/ParameterLists, Style/OptionalBooleanParameter

            def protected?
              @protected
            end

            def wrap?
              @wrap
            end

            def custom_text_properties?
              [color, font_weight].any? { |p| !p.nil? }
            end

            private

            def add_default_children!
              children << TableCellProperties.new(protected?, wrap: wrap?, doc: doc)
              children << TextProperties.new(color: color, font_weight: font_weight, doc: doc) if custom_text_properties?
            end
          end
        end
      end
    end
  end
end
