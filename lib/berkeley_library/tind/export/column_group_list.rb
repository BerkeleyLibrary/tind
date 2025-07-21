require 'berkeley_library/tind/export/filter'
require 'berkeley_library/tind/export/column_group'
require 'berkeley_library/tind/export/column'
require 'berkeley_library/tind/export/export_exception'
require 'berkeley_library/tind/export/row'
require 'berkeley_library/util/arrays'

module BerkeleyLibrary
  module TIND
    module Export
      class ColumnGroupList
        include Enumerable

        # ------------------------------------------------------------
        # Initializer

        def initialize(exportable_only: false)
          @exportable_only = exportable_only
        end

        # ------------------------------------------------------------
        # Accessors

        def exportable_only?
          @exportable_only
        end

        # ------------------------------------------------------------
        # Misc. instance methods

        def all_groups
          # NOTE: this isn't ||= because we only cache on #freeze
          @all_groups || begin
            all_tags = column_groups_by_tag.keys.sort
            all_tags.each_with_object([]) do |tag, groups|
              tag_column_groups = column_groups_by_tag[tag]
              groups.concat(tag_column_groups)
            end
          end
        end

        def add_data_fields(marc_record, row)
          # TODO: what about control fields?
          marc_record.data_fields_by_tag.each do |tag, data_fields|
            next unless can_export_tag?(tag)
            next if data_fields.empty?

            add_fields_at(data_fields, row)
          end
        rescue StandardError => e
          raise Export::ExportException, "Error adding MARC record #{marc_record.record_id} at row #{row}: #{e.message}"
        end

        # ------------------------------------------------------------
        # Enumerable

        def each(&block)
          all_groups.each(&block)
        end

        # ------------------------------------------------------------
        # Object overrides

        def freeze
          column_groups_by_tag.each_value(&:freeze)
          column_groups_by_tag.freeze
          @all_groups ||= all_groups.freeze
          self
        end

        def frozen?
          column_groups_by_tag.frozen? &&
            @all_groups && @all_groups.frozen?
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def column_groups_by_tag
          @column_groups_by_tag ||= {}
        end

        def add_fields_at(data_fields, row)
          tag = data_fields[0].tag.freeze
          tag_column_groups = (column_groups_by_tag[tag] ||= [])

          data_fields.inject(0) do |offset, df|
            next offset unless can_export_df?(df)

            1 + add_data_field(df, row, tag_column_groups, at_or_after: offset)
          end
        end

        def add_data_field(df, row, tag_column_groups, at_or_after: 0)
          added_at = added_at_index(df, row, tag_column_groups, at_or_after)
          return added_at if added_at

          new_group = ColumnGroup.new(df.tag, tag_column_groups.size, df.indicator1, df.indicator2, exportable_subfield_codes(df)).tap do |cg|
            raise Export::ExportException, "Unexpected failure to add #{df} to #{cg}" unless cg.maybe_add_at(row, df)
          end
          tag_column_groups << new_group
          tag_column_groups.size - 1
        end

        def added_at_index(df, row, tag_column_groups, at_or_after)
          BerkeleyLibrary::Util::Arrays.find_index(in_array: tag_column_groups, start_index: at_or_after) { |cg| cg.maybe_add_at(row, df) }
        end

        def can_export_tag?(tag)
          return true unless exportable_only?

          Filter.can_export_tag?(tag)
        end

        def can_export_df?(df)
          return true unless exportable_only?

          Filter.can_export_data_field?(df)
        end

        def exportable_subfield_codes(df)
          return df.subfield_codes unless exportable_only?

          Filter.exportable_subfield_codes(df)
        end
      end
    end
  end
end
