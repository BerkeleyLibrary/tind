require 'fileutils'
require 'zip'
require 'ucblit/util/ods/xml/content_doc'
require 'ucblit/util/ods/xml/styles_doc'
require 'ucblit/util/ods/xml/manifest_doc'

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

        # Returns the content document
        # @return [XML::ContentDoc] the container root-level content document
        def content
          @content ||= XML::ContentDoc.new
        end

        # Returns the container styles
        # @return [XML::StylesDoc] the container root-level style document
        def styles
          @styles ||= XML::StylesDoc.new
        end

        # Returns the container manifest
        # @return [XML::ManifestDoc] the container manifest document
        def manifest
          @manifest ||= XML::ManifestDoc.new
        end

        # Gets the document styles
        #
        # @return [UCBLIT::Util::ODS::XML::Office::AutomaticStyles] the styles
        def auto_styles
          content.document_content.automatic_styles
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
        #   Writes to the specified file. If `path` denotes a directory, the
        #   spreadsheet will be written as exploded, pretty-printed XML.
        #   @param path [String, Pathname] the path to the output file
        #   @return[void]
        #   @see UCBLIT::Util::ODS::Spreadsheet#write_exploded_to
        # noinspection RubyYardReturnMatch
        def write_to(out)
          return write_to_string unless out
          return write_to_stream(out) if out.respond_to?(:write)
          return write_exploded_to(out) if File.directory?(out)

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

        # Writes this spreadsheet as an exploded set of pretty-printed XML files.
        # NOTE: OpenOffice itself and many other tools get confused by the extra text
        # nodes in the pretty-printed files and won't read them properly; this method
        # is mostly for debugging.
        #
        # @return [Array<String>] a list of files written.
        def write_exploded_to(dir)
          raise ArgumentError, "Not a directory: #{dir.inspect}" unless File.directory?(dir)

          [].tap do |files_written|
            document_nodes.each do |doc|
              output_path = File.join(dir, doc.path)
              FileUtils.mkdir_p(File.dirname(output_path))
              doc.to_xml(output_path, compact: false)

              files_written << File.absolute_path(output_path)
            end
          end
        end

        # ------------------------------------------------------------
        # Private methods

        private

        # @return [Array<DocumentNode>] all documents to write to this container
        def document_nodes
          [manifest, styles, content]
        end

        # Returns true if `out` is IO-like enough for {Zip::OutputStream}, false otherwise
        # @return [Boolean] whether `out` can be passed to {Zip::OutputStream#write_buffer}
        def io_like?(out)
          out.respond_to?(:reopen) &&
          out.respond_to?(:rewind) &&
          out.respond_to?(:<<)
        end

        def write_zipfile(out)
          io = Zip::OutputStream.write_buffer(out) do |zip|
            document_nodes.each do |doc|
              zip.put_next_entry(doc.path)
              doc.to_xml(zip)
            end
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
