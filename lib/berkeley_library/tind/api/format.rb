require 'typesafe_enum'

module BerkeleyLibrary
  module TIND
    module API
      class Format < TypesafeEnum::Base
        %i[ID XML FILES JSON].each { |fmt| new(fmt) }

        def to_s
          # noinspection RubyYardReturnMatch
          value
        end

        def to_str
          value
        end

        class << self
          def ensure_format(format)
            return unless format
            return format if format.is_a?(Format)

            fmt = Format.find_by_value(format.to_s.downcase)
            return fmt if fmt

            raise ArgumentError, "Unknown #{Format}: #{format.inspect}"
          end
        end
      end
    end
  end
end
