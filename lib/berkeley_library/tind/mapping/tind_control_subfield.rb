require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module TindControlSubfield

        def extract_value(rule, value)
          pos = rule.position_from_to
          return nil unless pos

          value[pos[0]..pos[1]]
        end

        # return a mapped datafield based on rule and extract value
        def extracted_field(rule, sub_value)
          subname = rule.subfield_key
          destiantion_tag = rule.tag_destination
          indicator = rule.indicator
          return nil unless subname && destiantion_tag && indicator

          new_sub_value = clean_subfield_value(destiantion_tag, sub_value)
          return nil unless new_sub_value

          new_sub_value = clean_subfield_value(destiantion_tag, sub_value)
          subfields = [Util.subfield(subname, new_sub_value)]
          Util.datafield(destiantion_tag, indicator, subfields)
        end

        # pass in rules, a string value; return datafields based on rules
        def extracted_fields_from_leader(leader_rules, leader_value)
          new_fls = []
          leader_rules.each do |rule|
            sub_value = extract_value(rule, leader_value)
            next unless sub_value

            newfield = extracted_field(rule, sub_value)
            new_fls << newfield if newfield
          end
          new_fls
        end

        private

        def clean_subfield_value(tag, val)
          return val if tag != '269'

          new_val = val.downcase.sub(/u$/, '0')
          qualified_269?(new_val) ? new_val : nil
        end

        def qualified_269?(val)
          val =~ /^\d{4}$/
        end

      end
    end
  end
end
