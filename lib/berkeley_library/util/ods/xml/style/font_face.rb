require 'berkeley_library/util/ods/xml/element_node'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class FontFace < XML::ElementNode
            DEFAULT_FONT_FACE = 'Liberation Sans'.freeze

            attr_reader :name, :svg_family, :family_generic, :font_pitch

            def initialize(name, doc:, svg_family: nil, family_generic: nil, font_pitch: nil)
              super(:style, 'font-face', doc: doc)

              set_attribute('name', name)
              set_attribute(:svg, 'font-family', svg_family || to_family(name))
              set_attribute('font-family-generic', family_generic) if family_generic
              set_attribute('font-pitch', font_pitch) if font_pitch
            end

            class << self
              def default_face(doc:)
                FontFace.new(FontFace::DEFAULT_FONT_FACE, family_generic: 'swiss', font_pitch: 'variable', doc: doc)
              end
            end

            private

            def to_family(name)
              # TODO: https://www.w3.org/TR/CSS2/syndata.html#value-def-identifier
              name =~ /^[[:alpha:]][[:alnum:]]*$/ ? name : quote_name(name)
            end

            def quote_name(name)
              return name.inspect if name.include?("'")

              "'#{name}'"
            end

          end
        end
      end
    end
  end
end
