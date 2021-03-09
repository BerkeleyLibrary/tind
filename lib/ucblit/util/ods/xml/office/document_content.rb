require 'ucblit/util/ods/xml/namespace'
require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/office/scripts'
require 'ucblit/util/ods/xml/office/font_face_decls'
require 'ucblit/util/ods/xml/office/automatic_styles'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class DocumentContent < XML::ElementNode

            def initialize(doc:)
              super(:office, 'document-content', doc: doc)

              add_default_attributes!
              add_default_children!
            end

            def scripts
              @scripts ||= Scripts.new(doc: doc)
            end

            def font_face_decls
              @font_face_decls ||= Office::FontFaceDecls.new(doc: doc)
            end

            def automatic_styles
              @automatic_styles ||= Office::AutomaticStyles.new(doc: doc)
            end

            private

            def add_default_attributes!
              Namespace.each { |ns| add_attribute(:xmlns, ns.prefix, ns.uri) }
              add_attribute('version', '1.2')
            end

            def add_default_children!
              children << scripts
              children << font_face_decls
              children << automatic_styles
            end
          end
        end
      end
    end
  end
end
