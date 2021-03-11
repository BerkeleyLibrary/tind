require 'ucblit/util/ods/xml/content_doc'
require 'ucblit/util/ods/xml/styles_doc'
require 'ucblit/util/ods/xml/manifest_doc'
require 'zip'

module UCBLIT
  module Util
    module ODS
      class Spreadsheet

        # ------------------------------------------------------------
        # Utility methods

        # Adds a table ('worksheet') to the spreadsheet.
        #
        # @param name [String] the table name
        # @return [UCBLIT::Util::ODS::XML::Table::Table] a new table with the specified name
        def add_table(name)
          content.document_content.add_table(name)
        end

        # ------------------------------------------------------------
        # Accessors

        def content
          @content ||= XML::ContentDoc.new
        end

        def styles
          @styles ||= XML::StylesDoc.new
        end

        def manifest
          @manifest ||= XML::ManifestDoc.new
        end

        # ------------------------------------------------------------
        # Output

        # @overload write_to
        #   Writes to a new string.
        #   @return [String] a binary string containing the spreadsheet data.
        # @overload write_to(out)
        #   Writes to the specified output stream.
        #   @param out [IO] the output stream
        #   @return[void]
        # @overload write_to(path)
        #   Writes to the specified file.
        #   @param path [String, Pathname] the path to the output file
        #   @return[void]
        def write_to(out)
          return write_to_string unless out
          return write_to_stream(out) if out.respond_to?(:write)

          write_to_file(out)
        end

        # Writes to a new string.
        def write_to_string
          # noinspection RubyYardParamTypeMatch
          StringIO.new.tap { |out| write_to_stream(out) }.string
        end

        # Writes to the specified output stream.
        # @param out [IO]
        def write_to_stream(out)
          zip64_orig = Zip.write_zip64_support
          begin
            Zip.write_zip64_support = true
            write_zipfile(out)
          ensure
            Zip.write_zip64_support = zip64_orig
          end
        end

        # Writes to the specified file.
        # @param path [String, Pathname]
        def write_to_file(path)
          File.open(path, 'wb') { |f| write_to_stream(f) }
        end

        # ------------------------------------------------------------
        # Private methods

        private

        # Returns true if `out` is IO-like enough for {Zip::OutputStream}, false otherwise
        # @return [Boolean] whether `out` can be passed to {Zip::OutputStream#write_buffer}
        def io_like?(out)
          out.respond_to?(:reopen) &&
          out.respond_to?(:rewind) &&
          out.respond_to?(:<<)
        end

        def write_zipfile(out)
          io = Zip::OutputStream.write_buffer(out) do |zip|
            zip.put_next_entry('META-INF/manifest.xml')
            manifest.to_xml(zip)

            zip.put_next_entry('styles.xml')
            styles.to_xml(zip)

            zip.put_next_entry('content.xml')
            content.to_xml(zip)
          end
          # NOTE: Zip::OutputStream plays games with the stream and
          #   doesn't necessarily write everything unless flushed, see:
          #   https://github.com/rubyzip/rubyzip/issues/265
          io.flush
        end

      end
    end
  end
end
