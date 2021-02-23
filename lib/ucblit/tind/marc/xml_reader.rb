require 'nokogiri'
require 'marc/xml_parsers'
require 'marc_extensions'

module UCBLIT
  module TIND
    module MARC
      # A customized XML reader for reading MARC records from TIND search results.
      class XMLReader
        include Enumerable
        include ::MARC::NokogiriReader

        # ############################################################
        # Constant

        COMMENT_TOTAL_RE = /Search-Engine-Total-Number-Of-Results: ([0-9]+)/.freeze

        # ############################################################
        # Attributes

        attr_reader :search_id

        # Returns the total number of records, based on the `<total/>` tag
        # returned by the TIND Search API, or the special comment
        # `Search-Engine-Total-Number-Of-Results` returned by TIND
        # Regular Search in XML format.
        #
        # Note that the total is not guaranteed to be present, and if present,
        # may not be present unless at least some records have been parsed.
        #
        # @return [Integer, nil] the total number of records, or `nil` if the total has not been read yet
        def total
          @total&.to_i
        end

        # Returns the number of records yielded.
        #
        # @return [Integer] the number of records yielded.
        def records_yielded
          @records_yielded ||= 0
        end

        # ############################################################
        # Initializer

        # Reads MARC records from an XML datasource given either as a file path,
        # or as an IO object.
        #
        # @param source [String, Pathname, IO] the path to a file, or an IO to read from directly
        # @param freeze [Boolean] whether to freeze each record after reading
        def initialize(source, freeze: false)
          @handle = ensure_io(source)
          @freeze = freeze
          init
        end

        class << self
          include MARCExtensions::XMLReaderClassExtensions
        end

        # ############################################################
        # MARC::GenericPullParser overrides

        def yield_record
          @record[:record].freeze if @freeze
          super
        ensure
          increment_records_yielded!
        end

        # ############################################################
        # Nokogiri::XML::SAX::Document overrides

        # @see Nokogiri::XML::Sax::Document#start_element_namespace
        # rubocop:disable Metrics/ParameterLists
        def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
          super

          @current_element_name = name
        end
        # rubocop:enable Metrics/ParameterLists

        # @see Nokogiri::XML::Sax::Document#end_element_namespace
        def end_element_namespace(name, prefix = nil, uri = nil)
          super

          @current_element_name = nil
        end

        # @see Nokogiri::XML::Sax::Document#characters
        def characters(string)
          return unless (name = @current_element_name)

          case name
          when 'search_id'
            @search_id = string
          when 'total'
            @total = string.to_i
          else
            super
          end
        end

        # @see Nokogiri::XML::Sax::Document#comment
        def comment(string)
          return unless (md = COMMENT_TOTAL_RE.match(string))

          @total = md[1].to_i
        end

        # ############################################################
        # Private

        private

        def ensure_io(file)
          return file if file.respond_to?(:read)
          return File.new(file) if File.exist?(file)
          return StringIO.new(file) if file =~ /^\s*</x

          raise ArgumentError, "Don't know how to read XML from #{file.inspect}: not an IO, file path, or XML text"
        end

        def increment_records_yielded!
          @records_yielded = records_yielded + 1
        end
      end
    end
  end
end
