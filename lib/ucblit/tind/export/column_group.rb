require 'ucblit/tind/export/column'
require 'ucblit/util/arrays'

module UCBLIT
  module TIND
    module Export

      # A group of columns representing the subfields of a particular
      # data field.
      class ColumnGroup
        include UCBLIT::Util::Arrays

        # ------------------------------------------------------------
        # Accessors

        attr_reader :tag, :index_in_tag, :ind1, :ind2, :subfield_codes

        # ------------------------------------------------------------
        # Initializer

        def initialize(tag, index_in_tag, ind1, ind2, subfield_codes)
          @tag = tag
          @ind1 = valid_ind(ind1)
          @ind2 = valid_ind(ind2)
          @subfield_codes = subfield_codes.dup.freeze
          @index_in_tag = index_in_tag
        end

        # ------------------------------------------------------------
        # Class methods

        class << self

          def from_data_field(data_field, index_in_tag)
            raise ArgumentError, "Not a MARC data field: #{data_field}" unless data_field_like?(data_field)

            ColumnGroup.new(data_field.tag, index_in_tag, data_field.indicator1, data_field.indicator2, data_field.subfield_codes)
          end

          def data_field_like?(df)
            %i[tag indicator1 indicator2 subfield_codes].all? { |m| df.respond_to?(m) }
          end
        end

        # ------------------------------------------------------------
        # Instance methods

        def prefix
          [tag, format_ind(ind1), format_ind(ind2)].join
        end

        def maybe_add_at(row, data_field)
          warn "Data field at row #{row} is not frozen: #{data_field}" unless data_field.subfields.frozen?
          return unless can_add?(data_field)

          @subfield_codes = merge(subfield_codes, data_field.subfield_codes)
          data_fields[row] = data_field
        end

        def value_at(row, col)
          return unless (data_field = data_fields[row])
          return unless (subfield_indices = subfield_indices_for(row))
          return unless (subfield_index = subfield_indices[col])
          return unless (subfield = data_field.subfields[subfield_index])

          subfield.value
        end

        def columns
          @columns ||= (0...subfield_codes.length).map { |col| Column.new(self, col) }
        end

        # ------------------------------------------------------------
        # Object overrides

        def to_s
          "ColumnGroup #{tag}-#{index_in_tag}:" + [prefix, subfield_codes.join].join
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def can_add?(data_field)
          ColumnGroup.data_field_like?(data_field) &&
            data_field.tag == tag &&
            data_field.indicator1 == ind1 &&
            data_field.indicator2 == ind2
        end

        def subfield_indices_for(row)
          return cached_subfield_indices[row] if row < cached_subfield_indices.size
          return unless (data_field = data_fields[row])

          cached_subfield_indices[row] = find_subfield_indices(data_field)
        end

        def cached_subfield_indices
          @cached_subfield_indices ||= []
        end

        def find_subfield_indices(data_field)
          return unless can_add?(data_field)

          df_index_to_cg_index = find_indices(in_array: subfield_codes, for_array: data_field.subfield_codes)
          invert(df_index_to_cg_index)
        end

        def format_ind(ind)
          ind == ' ' ? '_' : ind
        end

        def valid_ind(ind)
          return ind if ind =~ /[0-9a-z ]/

          raise ArgumentError, "Not a valid indicator: #{ind.inspect}"
        end

        def data_fields
          @data_fields ||= []
        end

      end
    end
  end
end
