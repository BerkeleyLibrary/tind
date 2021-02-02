require 'marc_extensions'

require 'ucblit/util/arrays'

require 'ucblit/tind/marc_table/column_group'
require 'ucblit/tind/marc_table/column'
require 'ucblit/tind/marc_table/row'

module UCBLIT
  module TIND
    class MARCTable
      include UCBLIT::Util::Arrays

      class << self
        def from_records(records)
          records.each_with_object(MARCTable.new) { |r, t| t << r }
        end
      end

      # The MARC records
      #
      # @return [Array<MARC::Record>] the records
      def marc_records
        @marc_records ||= []
      end

      # The column headers
      #
      # @return [Array<String>] the column headers
      def headers
        columns.map(&:header)
      end

      # The columns
      #
      # @return [Array<Column>] the columns.
      def columns
        # TODO: cache if frozen
        column_groups.map(&:columns).flatten
      end

      # The number of columns (distinct subfields)
      #
      # @return [Integer] the number of columns
      def col_count
        columns.size
      end

      # The number of rows (records)
      #
      # @return [Integer] the number of rows
      def row_count
        marc_records.size
      end

      # Adds the specified record
      #
      # @param marc_record [MARC::Record] the record to add
      def <<(marc_record)
        warn 'MARC record is not frozen' unless marc_record.frozen?

        add_data_fields(marc_record, marc_records.size)

        marc_records << marc_record
        self
      end

      def values_for(row)
        columns.map { |c| c.value_at(row) }
      end

      def rows
        # TODO: lazy etc.
        (0...row_count).map { |row| Row.new(columns, row) }
      end

      private

      def column_groups
        all_tags.each_with_object([]) do |tag, groups|
          groups.append(*column_groups_by_tag[tag])
        end
      end

      def all_tags
        column_groups_by_tag.keys.sort
      end

      def column_groups_by_tag
        @column_groups_by_tag ||= {}
      end

      def add_data_fields(marc_record, row)
        marc_record.data_fields_by_tag.each do |tag, data_fields|
          tag_column_groups = (column_groups_by_tag[tag] ||= [])

          data_fields.inject(0) do |offset, df|
            1 + add_data_field(df, row, tag_column_groups, at_or_after: offset)
          end
        end
      end

      def add_data_field(data_field, row, tag_column_groups, at_or_after: 0)
        added_at = find_index(in_array: tag_column_groups, start_index: at_or_after) { |cg| cg.maybe_add_at(row, data_field) }
        return added_at if added_at

        new_group = ColumnGroup.from_data_field(data_field, tag_column_groups.size).tap do |cg|
          raise ArgumentError, "Unexpected failure to add #{data_field} to #{cg}" unless cg.maybe_add_at(row, data_field)
        end
        tag_column_groups << new_group
        tag_column_groups.size - 1
      end
    end
  end
end
