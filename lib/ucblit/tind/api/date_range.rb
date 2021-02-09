require 'ucblit/util/times'

module UCBLIT
  module TIND
    module API
      class DateRange
        include UCBLIT::Util::Times

        attr_reader :from_time, :until_time

        def initialize(from_time:, until_time:, mtime: false)
          @from_time = ensure_utc(from_time)
          @until_time = ensure_utc(until_time)
          @mtime = mtime
        end

        def mtime?
          @mtime
        end

        def to_params
          { d1: from_time, d2: from_time }.tap do |params|
            params[:dt] = 'm' if mtime?
          end
        end

        class << self
          def from_range(range)
            DateRange.new(from_time: range.first, until_time: range.last)
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
end
