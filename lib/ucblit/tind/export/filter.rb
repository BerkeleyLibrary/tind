module UCBLIT
  module TIND
    module Export
      module Filter
        DO_NOT_EXPORT_FIELDS = ['005', '8564 ', '902  ', '903  ', '991', '998'].map(&:freeze).freeze
        DO_NOT_EDIT_FIELDS = (['001'.freeze] + DO_NOT_EXPORT_FIELDS).freeze

        DO_NOT_EXPORT_SUBFIELDS = ['336  a', '852  c', '901  a', '901  f', '901  g', '980  a', '982  a', '982  b', '982  p'].map(&:freeze).freeze
        DO_NOT_EDIT_SUBFIELDS = (['035  a'.freeze] + DO_NOT_EXPORT_SUBFIELDS).freeze

        class << self
          def can_export_tag?(tag)
            !DO_NOT_EXPORT_FIELDS.include?(tag)
          end

          def can_export_data_field?(df)
            !exportable_subfield_codes(df).empty?
          end

          def exportable_subfield_codes(df)
            DO_NOT_EXPORT_FIELDS.each { |f| return [] if df_matches(df, f) }

            excluded_codes = DO_NOT_EXPORT_SUBFIELDS.select { |f| df_matches(df, f) }.map { |f| f[5] }
            return df.subfield_codes if excluded_codes.empty?

            df.subfield_codes.reject { |code| excluded_codes.include?(code) }
          end

          private

          def df_matches(df, f)
            f == df.tag ||
              f.size > 3 && f.start_with?(df.tag) &&
                f[3] == df.indicator1 && f[4] == df.indicator2
          end
        end
      end
    end
  end
end
