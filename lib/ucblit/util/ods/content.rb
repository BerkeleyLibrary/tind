require 'nokogiri'
require 'ucblit/util/ods/namespace'
require 'ucblit/util/ods/xml_element'
require 'ucblit/util/ods/scripts'
require 'ucblit/util/ods/automatic_styles'

module UCBLIT
  module Util
    module ODS
      class Content < XMLElement

        ENCODING = 'UTF-8'.freeze

        def initialize
          super(
            :office, 'document-content',
            doc: Nokogiri::XML::Document.new.tap { |doc| doc.encoding = ENCODING }
          )

          add_default_attributes!
          add_default_children!
        end

        def to_xml(out = nil)
          return write_xml_to_string unless out
          return write_xml_to_stream(out) if out.respond_to?(:write)

          write_xml_to_file(out)
        end

        def scripts
          @scripts ||= Scripts.new(doc: doc)
        end

        def font_face_decls
          @font_face_decls ||= FontFaceDecls.new(doc: doc)
        end

        def automatic_styles
          @automatic_styles ||= AutomaticStyles.new(doc: doc)
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

        def write_xml_to_stream(out)
          doc.root ||= element
          doc.write_to(out, encoding: ENCODING)
        end

        def write_xml_to_string
          StringIO.new.tap do |out|
            out.binmode
            write_xml_to_stream(out)
          end.string
        end

        def write_xml_to_file(path)
          File.open(path, 'wb') { write_xml_to_stream(out) }
        end
      end
    end
  end
end
