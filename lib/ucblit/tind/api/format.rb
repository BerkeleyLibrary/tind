require 'typesafe_enum'

module UCBLIT
  module TIND
    module API
      class Format < TypesafeEnum::Base
        new(:ID, 'id'.freeze)
        new(:XML, 'xml'.freeze)
        new(:FILES, 'files'.freeze)
        new(:JSON, 'json'.freeze)

        def to_s
          value
        end

        def to_str
          value
        end

        class << self
          def ensure_format(format)
            return unless format
            return format if format.is_a?(Format)

            fmt = Format.find_by_value(format.to_s)
            return fmt if fmt

            raise ArgumentError, "Can't convert #{format.inspect} to #{Format}"
          end
        end
      end
    end
  end
end
