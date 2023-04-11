require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module TindSubfieldUtil

        def clean_subfield(subfield)
          new_value = clr_value(subfield.value)
          subfield.value = new_value
        end

        def fields_880_subfield6(datafields_880)
          formated_subfield6_value_arr(fields_by(datafields_880) { |f| is_880_field?(f) })
        end

        # From all subfield 6 gotten for repeated fields - with the same tag
        # return the first subfield 6
        def the_first_subfield6(fields)
          values = subfield_6_values(fields)
          return nil if values.empty?

          # keep it here, in case needed in future: this can make sure
          # 880 and regular fields having matching sequence number
          # subfield6_with_small_no(values)

          # new implementation: keep the first subfield 6 value
          logger.warn("#{fields[0].tag} have multiple datafields with multiple subfield 6, the first subfield 6 is kept") if values.length > 1
          Util.subfield('6', values[0])
        end

        private

        def subfield6?(f)
          !f['6'].nil?
        end

        # f.tag can be a string or integer
        def is_880_field?(f)
          f.tag.to_s == '880'
        end

        # return subfield6 value formated the same way for both 880 and regular datafields
        def formated_subfield6_value(f)
          is_880_field?(f) ? formated_subfield6_from_880(f) : formated_subfield6_from_regular_field(f)
        end

        def fields_by(fields, &block)
          fields.select(&block)
        end

        # return array of formated subfield6 values on inputted datafields
        def formated_subfield6_value_arr(fields_source)
          # fields_source = is_880_field ? fields_880(datafields) : fields_regular(datafields)
          ls = []
          fields_source.map do |f|
            next unless subfield6?(f)

            ls << formated_subfield6_value(f)
          end
          ls.compact
        end

        # return formated field6 for a regular datafield
        # tag:246, subfields: 880-02 => 880-246-02
        def formated_subfield6_from_regular_field(f)
          return nil unless f['6']

          tag = f.tag
          arr = f['6'].strip.split('-')
          "#{arr[0]}-#{tag}-#{arr[1]}"
        end

        # return formated subfield6 for a 880 datafield
        # tag: 880, subfield6: 245-01/$1  => 880-245-01
        def formated_subfield6_from_880(f)
          return nil unless f['6']

          "#{f.tag}-#{f['6'].strip[0, 6].strip}"
        end

        # return subfields of specific code
        # Datafield returned from Alma may have mutiple subfields with the same code
        def subfields(field, code)
          sf = []
          field.each do |s|
            next unless s.code == code

            captilize_subfield(s) if code == '3'
            sf << s
          end
          sf
        end

        def captilize_subfield(subfield)
          new_value = subfield.value.capitalize
          subfield.value = new_value
        end

        # Combine multiple subfield values based on definition from csv file
        def combined_subfield_value(field, code, symbol)
          sf_arr = subfields(field, code)
          return '' if sf_arr.empty?

          sf_arr.map(&:value).join(symbol) << symbol # symbol exmaple ' -- '
        end

        # Mutilpe subfields in one field may have the same name
        # Get all subfields on 'from subfield name'
        # Change subfield names with 'to subfield name'
        def subfields_from_to(field, from, to)
          subfield_arr = subfields(field, from)
          subfield_arr.each { |sf| sf.code = to } if !subfield_arr.empty? && (from != to)
          subfield_arr
        end

        def subfield6_endwith_00?(f)
          return false unless is_880_field?(f)

          two_digits = f['6'].strip.split('-')[1][0..1]
          two_digits.to_s == '00'
        end

        def fields_with_subfield6(fields)
          fields.select { |f| subfield6?(f) }
        end

        # return subfield 6 with the smallest sequence number
        def subfield_6_values(fields)
          fields_with_subfield6(fields).map(&:value)
        end

        def subfield6_value_with_lowest_seq_no(values)
          seq = 9999
          txt = nil
          values.each do |val|
            num = seq_no(val)
            if (num > 0) && (num < seq)
              seq = num
              txt = val
            end
          end
          txt
        end

        # return all subfields except subfield6
        def subfields_without_subfield6(field)
          field.subfields.reject { |sf| sf.code == '6' }
        end

      end
    end
  end
end
