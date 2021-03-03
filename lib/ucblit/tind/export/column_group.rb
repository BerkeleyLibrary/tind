require 'ucblit/tind/export/column'
require 'ucblit/util/arrays'
require 'ucblit/util/strings'

module UCBLIT
  module TIND
    module Export

      # A group of columns representing the subfields of a particular
      # data field.
      class ColumnGroup
        include UCBLIT::Util::Arrays

        # ------------------------------------------------------------
        # Constants

        # Indicators SHOULD NOT be capital letters, but TIND internal fields
        # don't respect that. Thus the /i flag.
        INDICATOR_RE = /^[0-9a-z ]$/i.freeze

        SUBFIELD_CODE_RE = /^[0-9a-z]$/.freeze

        # ------------------------------------------------------------
        # Accessors

        attr_reader :tag, :index_in_tag, :ind1, :ind2, :subfield_codes

        # ------------------------------------------------------------
        # Initializer

        def initialize(tag, index_in_tag, ind1, ind2, subfield_codes)
          @tag, @ind1, @ind2 = valid_tag_and_indicators(tag, ind1, ind2)
          @subfield_codes = valid_subfield_codes(subfield_codes).dup.freeze
          @index_in_tag = index_in_tag
        end

        # ------------------------------------------------------------
        # Class methods

        class << self

          def prefix_for(data_field)
            format_prefix(data_field.tag, data_field.indicator1, data_field.indicator2)
          end

          def format_indicator(ind)
            ind == ' ' ? '_' : ind
          end

          def format_prefix(tag, ind1, ind2)
            [tag, format_indicator(ind1), format_indicator(ind2)].join
          end
        end

        # ------------------------------------------------------------
        # Instance methods

        def prefix
          ColumnGroup.format_prefix(tag, ind1, ind2)
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

        def valid_tag_and_indicators(tag, ind1, ind2)
          raise ArgumentError, "#{tag}#{ind1}#{ind2}: not a valid tag" unless tag.size == 3 && UCBLIT::Util::Strings.ascii_numeric?(tag)
          raise ArgumentError, "#{tag}#{ind1}#{ind2}: not a valid indicator: #{ind1.inspect}" unless ind1 =~ INDICATOR_RE
          raise ArgumentError, "#{tag}#{ind1}#{ind2}: not a valid indicator: #{ind2.inspect}" unless ind2 =~ INDICATOR_RE

          [tag, ind1, ind2]
        end

        def valid_subfield_codes(subfield_codes)
          subfield_codes.tap do |scc|
            raise ArgumentError, "Invalid subfield codes: #{scc.inspect}" unless scc.all? { |c| c =~ SUBFIELD_CODE_RE }
          end
        end

        def can_add?(data_field)
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
          ColumnGroup.format_indicator(ind)
        end

        def data_fields
          @data_fields ||= []
        end
      end
    end
  end
end
