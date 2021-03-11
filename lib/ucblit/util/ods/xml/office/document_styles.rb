require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/office/font_face_decls'
require 'ucblit/util/ods/xml/office/styles'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class DocumentStyles < XML::ElementNode
            REQUIRED_NAMESPACES = %i[office style fo].freeze

            def initialize(doc:)
              super(:office, 'document-styles', doc: doc)

              set_default_attributes!
              add_default_children!
            end

            private

            def required_namespaces
              @required_namespaces ||= REQUIRED_NAMESPACES.map { |p| Namespace.for_prefix(p) }
            end

            def set_default_attributes!
              required_namespaces.each { |ns| set_attribute(:xmlns, ns.prefix, ns.uri) }
            end

            def add_default_children!
              add_child(FontFaceDecls.new(doc: doc))
              add_child(Styles.new(doc: doc))
            end
          end
        end
      end
    end
  end
end
