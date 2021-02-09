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

        COMMENT_TOTAL_RE = /Search-Engine-Total-Number-Of-Results: [0-9]+/.freeze

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

        # ############################################################
        # Initializer

        def initialize(file)
          @handle = ensure_io(file)
          init
        end

        # @yieldparam record [MARC::Record] the record

        # @return record [MARC::Record]

        class << self
          include MARCExtensions::XMLReaderClassExtensions
        end

        # ############################################################
        # Nokogiri::XML::SAX::Document overrides

        # rubocop:disable Metrics/ParameterLists
        def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
          super
          @current_element_name = name
        end
        # rubocop:enable Metrics/ParameterLists

        def end_element_namespace(name, prefix = nil, uri = nil)
          super

          @current_element_name = nil
        end

        def characters(string)
          return unless (name = @current_element_name)

          case name
          when 'search_id'
            @search_id = string
          when 'total'
            @total = string.to_i
          end
        end

        def comment(string)
          return unless (md = COMMENT_TOTAL_RE.match(string))

          @total = md[1].to_i
        end

        # ############################################################
        # Private

        def ensure_io(file)
          return file if file.respond_to?(:read)

          File.new(file)
        end
      end
    end
  end
end
