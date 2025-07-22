require 'nokogiri'
require 'marc/xml_parsers'
require 'marc_extensions'
require 'berkeley_library/util/files'

module BerkeleyLibrary
  module TIND
    module MARC
      # A customized XML reader for reading MARC records from TIND search results.
      class XMLReader
        include Enumerable
        include ::MARC::NokogiriReader
        include BerkeleyLibrary::Util::Files

        # ############################################################
        # Constant

        COMMENT_TOTAL_RE = /Search-Engine-Total-Number-Of-Results: ([0-9]+)/

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

        # Reads MARC records from an XML datasource given either as an XML string, a file path,
        # or as an IO object.
        #
        # @param source [String, Pathname, IO] an XML string, the path to a file, or an IO to read from directly
        # @param freeze [Boolean] whether to freeze each record after reading
        def initialize(source, freeze: false)
          @handle = ensure_io(source)
          @freeze = freeze
          init
        end

        class << self
          # Reads MARC records from an XML datasource given either as an XML string, a file path,
          # or as an IO object.
          #
          # @param source [String, Pathname, IO] an XML string, the path to a file, or an IO to read from directly
          # @param freeze [Boolean] whether to freeze each record after reading
          def read(source, freeze: false)
            new(source, freeze: freeze)
          end
        end

        # ############################################################
        # MARC::GenericPullParser overrides

        def yield_record
          @record[:record].tap do |record|
            clean_cf_values(record)
            move_cf000_to_leader(record)
            record.freeze if @freeze
          end

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

        # TIND uses <controlfield tag="000"/> instead of <leader/>
        def move_cf000_to_leader(record)
          return unless (cf_000 = record['000'])

          record.leader = cf_000.value
          record.fields.delete(cf_000)
        end

        # TIND uses \ (0x5c), not space (0x32), for unspecified values in positional fields
        def clean_cf_values(record)
          record.each_control_field { |cf| cf.value = cf.value&.gsub('\\', ' ') }
        end

        def ensure_io(file)
          return file if reader_like?(file)
          return File.new(file) if file_exists?(file)
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
