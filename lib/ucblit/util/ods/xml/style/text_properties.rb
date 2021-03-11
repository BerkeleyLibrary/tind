require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TextProperties < ElementNode

            COLOR_RE = /^#[[:xdigit:]]{6}$/.freeze

            attr_reader :color, :font_name, :language, :country

            def initialize(doc:, color: nil, font_name: nil, language: 'en', country: 'US')
              super(:style, 'text-properties', doc: doc)
              @color = ensure_color(color)
              @font_name = font_name
              @language = language
              @country = country
              set_default_attributes!
            end

            private

            def set_default_attributes!
              set_attribute('font-name', font_name) if font_name
              set_attribute(:fo, 'language', language) if language
              set_attribute(:fo, 'country', country) if country
              set_attribute(:fo, 'color', color) if color
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
