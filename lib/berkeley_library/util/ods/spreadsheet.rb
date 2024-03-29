require 'fileutils'
require 'zip'
require 'berkeley_library/logging'
require 'berkeley_library/util/ods/xml/content_doc'
require 'berkeley_library/util/ods/xml/styles_doc'
require 'berkeley_library/util/ods/xml/manifest_doc'

module BerkeleyLibrary
  module Util
    module ODS
      class Spreadsheet
        include BerkeleyLibrary::Logging

        # ------------------------------------------------------------
        # Utility methods

        # Adds a table ('worksheet') to the spreadsheet.
        #
        # @param name [String] the table name
        # @param protected [Boolean] whether to protect the table
        # @return [BerkeleyLibrary::Util::ODS::XML::Table::Table] a new table with the specified name
        def add_table(name, protected: true)
          content.document_content.add_table(name, protected: protected)
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
          @manifest ||= XML::ManifestDoc.new.tap do |mf_doc|
            manifest = mf_doc.manifest
            manifest_docs.each { |doc| manifest.add_entry_for(doc) }
          end
        end

        # Gets the document styles
        #
        # @return [BerkeleyLibrary::Util::ODS::XML::Office::AutomaticStyles] the styles
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
        #   @see BerkeleyLibrary::Util::ODS::Spreadsheet#write_exploded_to
        # noinspection RubyYardReturnMatch
        def write_to(out = nil)
          return write_to_string unless out
          return write_to_stream(out) if io_like?(out)
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
            each_document do |doc|
              output_path = write_exploded(doc, dir)
              files_written << File.absolute_path(output_path)
              logger.debug("Wrote #{files_written.last}")
            end
          end
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def each_document(&block)
          yield manifest

          manifest_docs.each(&block)
        end

        def manifest_docs
          [styles, content]
        end

        # Returns true if `out` is IO-like enough for {Zip::OutputStream}, false otherwise
        # @return [Boolean] whether `out` can be passed to {Zip::OutputStream#write_buffer}
        def io_like?(out)
          %i[reopen rewind <<].all? { |m| out.respond_to?(m) }
        end

        def write_zipfile(out)
          io = Zip::OutputStream.write_buffer(out) do |zip|
            # Workaround for https://github.com/sparklemotion/nokogiri/issues/2773
            class << zip; def external_encoding; end; end

            each_document { |doc| write_zip_entry(doc, zip) }
          end
          # NOTE: Zip::OutputStream plays games with the stream and
          #   doesn't necessarily write everything unless flushed, see:
          #   https://github.com/rubyzip/rubyzip/issues/265
          io.flush
        end

        def write_zip_entry(doc, zip)
          zip.put_next_entry(doc.path)
          doc.to_xml(zip)
        end

        def write_exploded(doc, dir)
          output_path = File.join(dir, doc.path)
          FileUtils.mkdir_p(File.dirname(output_path))
          doc.to_xml(output_path, compact: false)
          output_path
        end

      end
    end
  end
end
