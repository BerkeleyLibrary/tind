require 'ucblit/util/ods/xml_element'

module UCBLIT
  module Util
    module ODS
      class FontFaceDecls < XMLElement
        def initialize(doc:)
          super(:office, 'font-face-decls', doc: doc)

          add_font_face(default_face)
        end

        def add_font_face(font_face)
          children << font_face
        end

        private

        def default_face
          FontFace.default_face(doc: doc)
        end
      end
    end
  end
end
