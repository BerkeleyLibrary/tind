require 'typesafe_enum'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          class Family < TypesafeEnum::Base
            # ------------------------------------------------------------
            # Enum instances

            # NOTE: declaration order is as they appear in spreadsheets saved from LibreOffice

            new(:TABLE_COLUMN, 'table-column') do
              def prefix
                'co'
              end
            end

            new(:TABLE_ROW, 'table-row') do
              def prefix
                'ro'
              end
            end

            new(:TABLE, 'table') do
              def prefix
                'ta'
              end
            end

            new(:TABLE_CELL, 'table-cell') do
              def prefix
                'ce'
              end
            end

            # ------------------------------------------------------------
            # Class methods

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

            # ------------------------------------------------------------
            # Public instance methods

            def split_name(style_name)
              return [nil, style_name] unless style_name.start_with?(prefix)

              [prefix, style_name[prefix.size..]]
            end

            def index_part(style_name)
              prefix, suffix = split_name(style_name)
              return unless prefix == self.prefix
              return unless (suffix_i = suffix.to_i).to_s == suffix

              suffix_i
            end

            # ------------------------------------------------------------
            # TypesafeEnum overrides

            def to_s
              # noinspection RubyYardReturnMatch
              value
            end

          end
        end
      end
    end
  end
end
