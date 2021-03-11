require 'nokogiri'

module UCBLIT
  module Util
    module ODS
      module XML
        class DocumentNode

          ENCODING = 'UTF-8'.freeze

          attr_reader :path

          # Initializes a new DocumentNode
          # @param path [String] the path to this document in the container
          def initialize(path)
            @path = path
          end

          def to_xml(out = nil, compact: true)
            return write_xml_to_string(compact: compact) unless out
            return write_xml_to_stream(out, compact: compact) if out.respond_to?(:write)

            write_xml_to_file(out, compact: compact)
          end

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
            File.open(path, 'wb') { |f| write_xml_to_stream(f, compact: compact) }
          end
        end
      end
    end
  end
end
