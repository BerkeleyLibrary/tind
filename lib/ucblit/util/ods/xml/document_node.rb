require 'nokogiri'

module UCBLIT
  module Util
    module ODS
      module XML
        class DocumentNode

          ENCODING = 'UTF-8'.freeze

          def to_xml(out = nil, compact: true)
            return write_xml_to_string(compact: compact) unless out
            return write_xml_to_stream(out, compact: compact) if out.respond_to?(:write)

            write_xml_to_file(out, compact: compact)
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

          def write_xml_to_stream(out, compact:)
            doc.root ||= root_element_node.element
            if compact
              doc.write_to(out, encoding: ENCODING, save_with: 0)
            else
              doc.write_to(out, encoding: ENCODING)
            end
          end

          def write_xml_to_string(compact:)
            StringIO.new.tap do |out|
              out.binmode
              write_xml_to_stream(out, compact: compact)
            end.string
          end

          def write_xml_to_file(path, compact:)
            File.open(path, 'wb') { write_xml_to_stream(out, compact: compact) }
          end
        end
      end
    end
  end
end
