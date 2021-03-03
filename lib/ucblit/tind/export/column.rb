require 'marc_extensions'

module UCBLIT
  module TIND
    module Export
      class Column
        attr_reader :col_in_group
        attr_reader :column_group

        def initialize(column_group, col_in_group)
          @column_group = column_group
          @col_in_group = col_in_group
        end

        def header
          # NOTE: that TIND "-#" suffixes must be unique by tag, not tag + ind1 + ind2
          @header ||= "#{column_group.prefix}#{subfield_code}-#{1 + column_group.index_in_tag}"
        end

        def subfield_code
          @subfield_code ||= column_group.subfield_codes[col_in_group]
        end

        def value_at(row)
          column_group.value_at(row, col_in_group)
        end

        class << self
          HEADER_RE = /^(?<tag>[0-9]{3})(?<ind1>[0-9a-z_])(?<ind2>[0-9a-z_])(?<subfield_code>[0-9a-z])/.freeze

          def values_for(header, marc_record)
            tag, ind1, ind2, subfield_code = decompose_header(header)
            [].tap do |values|
              marc_record.each_field_with(tag: tag, ind1: ind1, ind2: ind2) do |df|
                df.subfields.each do |sf|
                  next unless sf.code == subfield_code

                  values << sf.value unless sf.value.to_s == ''
                end
              end
            end
          end

          private

          def decompose_header(header)
            raise ArgumentError, "Not a table column header: #{header.inspect}" unless (md = HEADER_RE.match(header))

            tag = md['tag']
            ind1 = md['ind1'] == '_' ? ' ' : md['ind1']
            ind2 = md['ind2'] == '_' ? ' ' : md['ind2']
            subfield_code = md['subfield_code']

            [tag, ind1, ind2, subfield_code]
          end

        end
      end
    end
  end
end
