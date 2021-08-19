require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class TextProperties < ElementNode

            FONT_WEIGHT_ATTRS = %w[font-weight font-weight-asian font-weight-complex].freeze
            COLOR_RE = /^#[[:xdigit:]]{6}$/.freeze

            attr_reader :color, :font_name, :language, :country, :font_weight

            # rubocop:disable Metrics/ParameterLists, Style/KeywordParametersOrder
            def initialize(color: nil, font_name: nil, font_weight: nil, language: 'en', country: 'US', doc:)
              super(:style, 'text-properties', doc: doc)
              @color = ensure_color(color)
              @font_name = font_name
              @language = language
              @country = country
              @font_weight = font_weight
              set_default_attributes!
            end
            # rubocop:enable Metrics/ParameterLists, Style/KeywordParametersOrder

            private

            def set_default_attributes!
              set_attribute('font-name', font_name) if font_name
              set_attribute(:fo, 'language', language) if language
              set_attribute(:fo, 'country', country) if country
              set_attribute(:fo, 'color', color) if color
              set_font_weight_attributes!
            end

            def set_font_weight_attributes!
              FONT_WEIGHT_ATTRS.each { |attr| set_attribute(:fo, attr, font_weight) } if font_weight
            end

            def ensure_color(color)
              return unless color
              raise ArgumentError, "Not a valid hex color: #{color.inspect}" unless color =~ COLOR_RE

              color.downcase
            end
          end
        end
      end
    end
  end
end
