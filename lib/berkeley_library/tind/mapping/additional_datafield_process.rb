# 1. Combine repeated fields
# 2. Sort subfields
# 3. Remove characters pre_defined
module BerkeleyLibrary
  module TIND
    module Mapping
      module AdditionalDatafieldProcess

        # process 1: remove and combine repeated fields - defined in Config module
        def remove_repeats(fields)
          Config.no_duplicated_tags.each { |tag| remove_repeated_fields(tag, fields) }
          fields
        end

        # process 2: remove charaters in subfields defined in Config module
        def clean_subfields(fields)
          fields.each do |f|
            next unless field_in_tags?(f, Config.clean_tags)

            clean_subfields_in_field(f)
          end
          fields
        end

        # 1. Find all datafield with the tag,
        #    if more than one found, combine repeated datafields which have a same tag into one
        # 2. Find all 880 datafields with subfield6 referring to the tag,
        #    if more than one found, combine repeated datafields with one subfield 6,
        #    a related datafield will be modified to have the same sequence in subfield 6 as in this 880 subfield 6
        def remove_repeated_fields(tag, fields)
          repeated_fields = fields_on_tag(tag, fields)
          remove_repeated(repeated_fields, fields)

          repeated_880_fields = fields_880_on_subfield6_referredtag(tag, fields)
          remove_repeated(repeated_880_fields, fields)
          fields
        end

        # clean subfields of a datafield
        def clean_subfields_in_field(field)
          field.subfields.each { |sf| clean_subfield(sf) }
        end

        private

        def field_in_tags?(field, tags)
          tag = field.tag
          tag_to_match = tag == '880' ? referred_tag(field) : tag
          return false unless tag_to_match

          tags.include? tag_to_match
        end

        def fields_on_tag(tag, fields)
          fields.select { |f| f.tag == tag }
        end

        def fields_880_on_subfield6_referredtag(tag, fields)
          fields.select { |f| field_880_has_referred_tag?(tag, f) }
        end

        # Marc with tag in 'Config.no_duplicated_tags' are not supposed to have the same multiple subfields
        # but sometime, sourc data error happens
        # solution:
        # taking the first subfield 6
        # taking the first other subfield when there are multiple same subfields
        # if 880 and regular field having unmatching subfield 6 in sequnce number, they will go to log file
        # A user will check the log and correct data in Alma or TIND accordingly
        def combined_subfields(fields)
          sf_arr = []
          subfield_6 = the_first_subfield6(fields)
          sf_arr << subfield_6 if subfield_6
          identical_subfields = no_duplicated_first_subfields(fields)
          sf_arr.concat identical_subfields
          sf_arr
        end

        # if there are multiple same subfields, pick up the first one, ignore the others
        def no_duplicated_first_subfields(fields)
          indentical_subfields = []

          fields.each do |f|
            subfields = subfields_without_subfield6(f)
            subfields.each { |sf| indentical_subfields << sf if not_in_identical_subfields?(indentical_subfields, sf) }
          end

          indentical_subfields
        end

        def subfield_codes(subfields)
          subfields.map(&:code)
        end

        def not_in_identical_subfields?(subfields, subfield)
          !subfield_codes(subfields).include? subfield.code
        end

        # return a combined datafield from repeated datafields - with the same tag
        def identical_field(repeated_fields)
          tag = repeated_fields[0].tag
          indicator = first_indicator(repeated_fields)
          subfield_arr = combined_subfields(repeated_fields)
          Util.datafield(tag, indicator, subfield_arr)
        end

        # remove repeated fields
        def rm_fields(fields_tobe_removed, fields)
          fields.delete_if { |f| fields_tobe_removed.include? f }
        end

        # suppose all repeated datafield have the same indictor
        def first_indicator(fields)
          indicator1 = fields[0].indicator1
          indicator2 = fields[0].indicator2
          [indicator1, indicator2]
        end

        # remove and keep one repeated datafield
        def remove_repeated(repeated_fields, fields)
          return fields unless repeated_fields.length > 1

          rm_fields(repeated_fields, fields)
          fields << identical_field(repeated_fields)
          fields
        end
      end
    end
  end
end
