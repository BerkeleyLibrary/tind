require 'berkeley_library/util/ods/xml/element_node'
require 'berkeley_library/util/ods/xml/style/font_face'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Office
          class FontFaceDecls < XML::ElementNode
            def initialize(doc:)
              super(:office, 'font-face-decls', doc: doc)

              add_font_face(default_face)
            end

            def add_font_face(font_face)
              children << font_face
            end

            private

            def default_face
              Style::FontFace.default_face(doc: doc)
            end
          end
        end
      end
    end
  end
end
