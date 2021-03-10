require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class TextProperties < ElementNode

            COLOR_RE = /^#[[:xdigit:]]{6}$/.freeze

            attr_reader :color

            def initialize(color, doc:)
              super(:table, 'text-properties', doc: doc)
              @color = ensure_color(color)
              add_default_attributes!
            end

            private

            def add_default_attributes!
              add_attribute(:fo, 'color', color)
            end

            def ensure_color(color)
              raise ArgumentError, "Not a valid hex color: #{color.inspect}" unless color =~ COLOR_RE

              color.downcase
            end
          end
        end
      end
    end
  end
end
