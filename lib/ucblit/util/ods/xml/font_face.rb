require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        class FontFace < ElementNode
          attr_reader :name, :svg_family, :family_generic, :font_pitch

          def initialize(name, doc:, svg_family: nil, family_generic: nil, font_pitch: nil)
            super(:style, 'font-face', doc: doc)

            add_attribute('name', name)
            add_attribute(:svg, 'font-family', svg_family || to_family(name))
            add_attribute('font-family-generic', family_generic) if family_generic
            add_attribute('font-pitch', font_pitch) if font_pitch
          end

          class << self
            def default_face(doc:)
              FontFace.new('Arial', family_generic: 'swiss', font_pitch: 'variable', doc: doc)
            end
          end

          private

          def to_family(name)
            # TODO: https://www.w3.org/TR/CSS2/syndata.html#value-def-identifier
            name =~ /^[[:alpha:]][[:alnum:]]*$/ ? name : name.inspect
          end

        end
      end
    end
  end
end
