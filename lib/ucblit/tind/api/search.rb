require 'ucblit/tind/api/date_range'
require 'ucblit/tind/api/format'

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

        def to_params
          {}.tap do |params|
            params[:c] = collection if collection
            params[:p] = pattern if pattern
            params[:f] = index if index
            params.merge!(date_range.to_params) if date_range
            params[:format] = format.to_s if format
          end
        end

        def result
          # TODO: handle pagination
          # TODO: handle other content types(?)
          # TODO: convert to MARC(?)
          @result ||= API.get(:search, to_params)
        end
      end
    end
  end
end
