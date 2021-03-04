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
      end
    end
  end
end
