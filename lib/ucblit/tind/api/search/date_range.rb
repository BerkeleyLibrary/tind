require 'ucblit/util/times'

module UCBLIT
  module TIND
    module API
      module Search
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
          end
        end
      end
    end
  end
end
