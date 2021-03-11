require 'ucblit/util/ods/xml/content_doc'
require 'ucblit/util/ods/xml/styles_doc'
require 'ucblit/util/ods/xml/manifest_doc'
require 'zip'

module UCBLIT
  module Util
    module ODS
      class Spreadsheet

        def content
          @content ||= XML::ContentDoc.new
        end

        def styles
          @styles ||= XML::StylesDoc.new
        end

        def manifest
          @manifest ||= XML::ManifestDoc.new
        end

        def add_table(name)
          content.document_content.add_table(name)
        end

        def write_to(out)
          zos = Zip::OutputStream.write_buffer(out) do |stream|
            stream.put_next_entry('META-INF/manifest.xml')
            manifest.to_xml(stream)

            stream.put_next_entry('styles.xml')
            styles.to_xml(stream)

            stream.put_next_entry('content.xml')
            content.to_xml(stream)
          end
          zos.flush
        end

        class << self
          Zip.write_zip64_support = true
        end
      end
    end
  end
end
