require 'ucblit/util/logging'
require 'ucblit/tind/marc/xml_reader'
require 'ucblit/tind/api/date_range'
require 'ucblit/tind/api/format'

module UCBLIT
  module TIND
    module API
      class Search
        include UCBLIT::Logging

        attr_reader :collection, :pattern, :index, :date_range, :format

        def initialize(collection: nil, pattern: nil, index: nil, date_range: nil, format: Format::XML)
          raise ArgumentError, 'Search requires a collection' unless collection

          @collection = collection
          @pattern = pattern
          @index = index
          @date_range = DateRange.ensure_date_range(date_range)
          @format = Format.ensure_format(format)
        end

        # rubocop: disable Metrics/AbcSize
        def params
          @params ||= {}.tap do |params|
            params[:c] = collection if collection
            params[:p] = pattern if pattern
            params[:f] = index if index
            params.merge!(date_range.to_params) if date_range
            params[:format] = self.format.to_s if self.format
          end
        end
        # rubocop: enable Metrics/AbcSize

        # Performs this search and returns the results as array.
        # @return [Array<MARC::Record>] the results
        def results
          each_result.to_a
        end

        # Iterates over the records returned by this search.
        # @overload each_result(freeze: false, &block)
        #   Yields each record to the provided block.
        #   @param freeze [Boolean] whether to freeze each record before yielding.
        #   @yieldparam marc_record [MARC::Record] each record
        #   @return [self]
        # @overload each_result(freeze: false)
        #   Returns an enumerator of the records.
        #   @param freeze [Boolean] whether to freeze each record before yielding.
        #   @return [Enumerable<MARC::Record>] the records
        def each_result(freeze: false, &block)
          return to_enum(:each_result, freeze: freeze) unless block_given?

          perform_search(freeze: freeze, &block)
          self
        end

        private

        def perform_search(search_id: nil, freeze: false, &block)
          logger.info("perform_search(search_id: #{search_id.inspect})")
          params = search_id ? self.params.merge(search_id: search_id) : self.params
          next_search_id = perform_single_search(params, freeze, &block)
          perform_search(search_id: next_search_id, freeze: freeze, &block) if next_search_id
        end

        def perform_single_search(params, freeze, &block)
          API.get(:search, params) do |body|
            process_body(body, freeze, &block)
          ensure
            body.close
          end
        rescue APIException => e
          return nil if empty_result?(e)

          raise
        end

        def process_body(body, freeze, &block)
          xml_reader = UCBLIT::TIND::MARC::XMLReader.read(body, freeze: freeze)
          xml_reader.each(&block)
          logger.debug("yielded #{xml_reader.records_yielded} of #{xml_reader.total} records")
          logger.debug("next search ID: #{xml_reader.search_id}")
          xml_reader.search_id if xml_reader.records_yielded > 0
        end

        def empty_result?(api_ex)
          return false unless api_ex.status_code == 500
          return false unless (body = api_ex.body)
          return false unless (result = JSON.parse(body, symbolize_names: true))

          result[:success] == false && result[:error].include?('0 values')
        rescue JSON::ParserError
          false
        end
      end
    end
  end
end
