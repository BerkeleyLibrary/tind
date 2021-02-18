require 'ucblit/util/times'
require 'ucblit/tind/config'

module UCBLIT
  module TIND
    module API
      class DateRange
        FORMAT = '%Y-%m-%d %H:%M:%S'.freeze

        attr_reader :from_time, :until_time

        def initialize(from_time:, until_time:, mtime: false)
          @from_time, @until_time = DateRange.ensure_valid_range(from_time, until_time)
          @mtime = mtime
        end

        def mtime?
          @mtime
        end

        def to_params
          { d1: format_param(from_time), d2: format_param(until_time) }.tap do |params|
            params[:dt] = 'm' if mtime?
          end
        end

        alias eql ==

        def ==(other)
          return false unless other.class == self.class

          [from_time, until_time] == [other.from_time, other.until_time]
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

          def ensure_valid_range(from_time, until_time)
            ftime, utime = [from_time, until_time].map { |t| UCBLIT::Util::Times.ensure_utc(t) }
            return [ftime, utime] if ftime <= utime

            raise ArgumentError, "Not a valid range: #{from_time.inspect}..#{until_time.inspect}"
          end
        end

        private

        def format_param(t)
          tz = UCBLIT::TIND::Config.timezone
          t_utc = UCBLIT::Util::Times.ensure_utc(t) # just to be sure
          t_local = tz.utc_to_local(t_utc)
          t_local.strftime(FORMAT)
        end
      end
    end
  end
end
