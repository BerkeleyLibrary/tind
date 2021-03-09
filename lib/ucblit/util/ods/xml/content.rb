require 'nokogiri'
require 'ucblit/util/ods/xml/document_content'

module UCBLIT
  module Util
    module ODS
      module XML
        class Content

          ENCODING = 'UTF-8'.freeze

          def to_xml(out = nil)
            return write_xml_to_string unless out
            return write_xml_to_stream(out) if out.respond_to?(:write)

            write_xml_to_file(out)
          end

          def document_content
            @document_content ||= DocumentContent.new(doc: doc)
          end

          private

          def doc
            @doc ||= Nokogiri::XML::Document.new.tap do |doc|
              doc.encoding = ENCODING
            end
          end

          def write_xml_to_stream(out)
            doc.root ||= document_content.element
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
end
