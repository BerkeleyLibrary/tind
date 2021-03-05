module UCBLIT
  module TIND
    module Export
      module Filter
        DO_NOT_EXPORT_FIELDS = ['005', '8564 ', '902  ', '903  ', '991', '998'].map(&:freeze).freeze
        DO_NOT_EDIT_FIELDS = (['001'.freeze] + DO_NOT_EXPORT_FIELDS).freeze

        DO_NOT_EXPORT_SUBFIELDS = ['336  a', '852  c', '901  a', '901  f', '901  g', '980  a', '982  a', '982  b', '982  p'].map(&:freeze).freeze
        DO_NOT_EDIT_SUBFIELDS = (['035  a'.freeze] + DO_NOT_EXPORT_SUBFIELDS).freeze

        DO_NOT_EDIT = (DO_NOT_EDIT_FIELDS + DO_NOT_EDIT_SUBFIELDS).freeze

        class << self
          def can_export_tag?(tag)
            !DO_NOT_EXPORT_FIELDS.include?(tag)
          end

          def can_export_data_field?(df)
            !exportable_subfield_codes(df).empty?
          end

          def exportable_subfield_codes(df)
            tag, ind1, ind2 = decompose_field(df)
            DO_NOT_EXPORT_FIELDS.each { |f| return [] if excludes?(f, tag, ind1, ind2) }

            excluded_codes = DO_NOT_EXPORT_SUBFIELDS.select { |f| excludes?(f, tag, ind1, ind2) }.map { |f| f[5] }
            return df.subfield_codes if excluded_codes.empty?

            df.subfield_codes.reject { |code| excluded_codes.include?(code) }
          end

          def can_edit?(tag, ind1, ind2, code)
            DO_NOT_EDIT.none? { |f| excludes?(f, tag, ind1, ind2, code) }
          end

          private

          def decompose_field(df)
            [df.tag, df.indicator1, df.indicator2]
          end

          def excludes?(f, tag, ind1, ind2, code = nil)
            return f == tag if f.size == 3

            excludes_tag = f.start_with?(tag) && f[3] == ind1 && f[4] == ind2
            code ? excludes_tag && code : excludes_tag
          end
        end
      end
    end
  end
end
