require 'nokogiri'

module UCBLIT
  module Util
    module ODS
      module XML
        class DocumentNode

          ENCODING = 'UTF-8'.freeze

          def to_xml(out = nil)
            return write_xml_to_string unless out
            return write_xml_to_stream(out) if out.respond_to?(:write)

            write_xml_to_file(out)
          end

          def root_element_node
            raise ArgumentError, "#{self.class} must implement #{DocumentNode}#root_element_node"
          end

          protected

          def doc
            @doc ||= Nokogiri::XML::Document.new.tap do |doc|
              doc.encoding = ENCODING
            end
          end

          private

          def write_xml_to_stream(out)
            doc.root ||= root_element_node.element
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
