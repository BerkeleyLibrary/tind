require 'ucblit/tind/config'
require 'ucblit/tind/api/search/date_range'
require 'ucblit/tind/api/format'

module UCBLIT
  module TIND
    module API
      module Search
        class Parameters
          attr_reader :collection, :pattern, :index, :date_range, :format

          def initialize(collection: nil, pattern: nil, index: nil, date_range: nil, format: Format::XML)
            @collection = collection
            @pattern = pattern
            @index = index
            @date_range = ensure_date_range(date_range)
            @format = ensure_format(format)
          end
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

        private

        def ensure_format(format)
          return unless format
          return format if format.is_a?(Format)
          raise ArgumentError, "Can't convert #{format.inspect} to #{Format}" unless (fmt = Format.find_by_value(format))

          fmt
        end

        def ensure_date_range(date_range)
          return unless date_range
          return date_range if date_range.is_a?(DateRange)
          return DateRange.from_range(date_range) if date_range.respond_to?(:first) && date_range.respond_to?(:last)

          raise ArgumentError, "Can't convert #{date_range.inspect} to #{DateRange}"
        end
      end
    end
  end
end
