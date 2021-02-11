require 'ucblit/tind/api/date_range'
require 'ucblit/tind/api/format'
require 'ucblit/tind/marc/xml_reader'

module UCBLIT
  module TIND
    module API
      class Search
        attr_reader :collection, :pattern, :index, :date_range, :format

        def initialize(collection: nil, pattern: nil, index: nil, date_range: nil, format: Format::XML)
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
            params[:format] = format.to_s if format
          end
        end
        # rubocop: enable Metrics/AbcSize

        # Performs this search and returns the results as array.
        # @return [Array<MARC::Record>] the results
        def results
          each_result.to_a
        end

        # Iterates over the records returned by this search.
        # @overload each_result(&block)
        #   Yields each record to the provided block.
        #   @yieldparam [MARC::Record] each record
        # @overload each_result
        #   Returns an enumerator of the records.
        #   @return [Enumerable<MARC::Record>] the records
        def each_result(&block)
          return to_enum(:each_result) unless block_given?

          perform_search(&block)
          self
        end

        private

        def perform_search(search_id: nil, &block)
          params = search_id ? self.params.merge(search_id: search_id) : self.params
          search_id = API.get(:search, params) do |body|
            xml_reader = UCBLIT::TIND::MARC::XMLReader.new(body)
            xml_reader.each(&block)
            xml_reader.search_id
          ensure
            body.close
          end
          perform_search(search_id: search_id, &block) if search_id
        end
      end
    end
  end
end
