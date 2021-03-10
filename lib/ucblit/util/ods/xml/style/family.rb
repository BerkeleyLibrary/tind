require 'typesafe_enum'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class Family < TypesafeEnum::Base
            new(:TABLE_CELL, 'table-cell', 'ce')
            new(:TABLE_COLUMN, 'table-column', 'co')
            new(:TABLE_ROW, 'table-row', 'ro')
            new(:TABLE, 'table', 'ta')

            attr_reader :name_prefix

            def initialize(key, value, name_prefix)
              super(key, value)

              @name_prefix = name_prefix
            end

            def to_s
              # noinspection RubyYardReturnMatch
              value
            end

            def next_name(names)
              prefixed_names = names.lazy.select do |n|
                next false unless n.start_with(prefix)

                n[prefix.size..] =~ /^[0-9]+$/
              end

              last_index = prefixed_names.map { |n| n[prefix.size..].to_i }.max
              "#{prefix}#{last_index + 1}"
            end

            class << self
              def from_string(str)
                find_by_key(str.to_s.upcase.to_sym) ||
                  find_by_value_str(str.to_s.downcase)
              end

              def ensure_family(f)
                family = f.is_a?(Family) ? f : Family.from_string(f)
                return family if family

                raise ArgumentError, "Not a style family: #{f.inspect}"
              end
            end
          end
        end
      end
    end
  end
end
