require 'nokogiri'
require 'marc_extensions'
require 'berkeley_library/tind/marc/xml_builder'

module BerkeleyLibrary
  module TIND
    module MARC
      class XMLWriter
        include BerkeleyLibrary::Util::Files
        include BerkeleyLibrary::Logging

        # ------------------------------------------------------------
        # Constants

        UTF_8 = Encoding::UTF_8.name

        EMPTY_COLLECTION_DOC = Nokogiri::XML::Builder.new(encoding: UTF_8) do |xml|
          xml.collection(xmlns: ::MARC::MARC_NS)
        end.doc.freeze

        COLLECTION_CLOSING_TAG = '</collection>'.freeze

        DEFAULT_NOKOGIRI_OPTS = { encoding: UTF_8 }.freeze

        # ------------------------------------------------------------
        # Fields

        attr_reader :out
        attr_reader :nokogiri_options

        # ------------------------------------------------------------
        # Initializer

        # Initializes a new {XMLWriter}.
        #
        # ```ruby
        # File.open('marc.xml', 'wb') do |f|
        #   w = XMLWriter.new(f)
        #   marc_records.each { |r| w.write(r) }
        #   w.close
        # end
        # ```
        #
        # @param out [IO, String] an IO, or the name of a file
        # @param nokogiri_options [Hash] Options passed to
        #   {https://nokogiri.org/rdoc/Nokogiri/XML/Node.html#method-i-write_to Nokogiri::XML::Node#write_to}
        #   Note that the `encoding` option is ignored, except insofar as
        #   passing an encoding other than UTF-8 will raise an `ArgumentError`.
        # @raise ArgumentError if `out` is not an IO or a string, or is a string referencing
        #   a file path that cannot be opened for writing; or if an encoding other than UTF-8
        #   is specified in `nokogiri-options`
        # @see #open
        def initialize(out, **nokogiri_options)
          @nokogiri_options = valid_nokogiri_options(nokogiri_options)
          @out = ensure_io(out)
        end

        # ------------------------------------------------------------
        # Class methods

        class << self

          # Opens a new {XMLWriter} with the specified output destination and
          # Nokogiri options, writes the XML prolog and opening `<collection>`
          # tag, yields the writer to write one or more MARC records, and closes
          # the writer.
          #
          # ```ruby
          # XMLWriter.open('marc.xml') do |w|
          #   marc_records.each { |r| w.write(r) }
          # end
          # ```
          #
          # Note that unlike initializing a writer with {#new} and closing it
          # immediately, this will write an XML document with an empty
          # `<collection></collection>` tag even if no records are written.
          #
          # @yieldparam writer [XMLWriter] the writer
          # @see #new
          # @see #close
          def open(out, **nokogiri_options)
            writer = new(out, **nokogiri_options)
            writer.send(:ensure_open!)
            yield writer if block_given?
            writer.close
          end
        end

        # ------------------------------------------------------------
        # Instance methods

        # Writes the specified record to the underlying stream, writing the
        # XML prolog and opening `<collection>` tag if they have not yet
        # been written.
        #
        # @param record [::MARC::Record] the MARC record to write.
        # @raise IOError if the underlying stream has already been closed.
        def write(record)
          ensure_open!
          record_element = XMLBuilder.new(record).build
          record_element.write_to(out, nokogiri_options)
          out.write("\n")
        end

        # Closes the underlying stream. If the XML prolog and opening `<collection>`
        # tag have already been written, the closing `<collection/>` tag is written
        # first.
        def close
          out.write(COLLECTION_CLOSING_TAG) if @open
          out.close
        end

        # ------------------------------------------------------------
        # Private

        private

        def ensure_open!
          return if @open

          out.write(prolog_and_opening_tag)
          @open = true
        end

        def prolog_and_opening_tag
          StringIO.open do |tmp|
            EMPTY_COLLECTION_DOC.write_to(tmp, nokogiri_options)
            result = tmp.string
            result.sub!(%r{/>\s*$}, ">\n")
            result
          end
        end

        def ensure_io(file)
          return file if writer_like?(file)
          return File.open(file, 'wb') if parent_exists?(file)

          raise ArgumentError, "Don't know how to write XML to #{file.inspect}: not an IO or file path"
        end

        def valid_nokogiri_options(opts)
          if (encoding = opts.delete(:encoding)) && encoding != UTF_8
            raise ArgumentError, "#{self.class.name} only supports #{UTF_8}; unable to use specified encoding #{encoding}"
          end

          DEFAULT_NOKOGIRI_OPTS.merge(opts)
        end

      end
    end
  end
end
