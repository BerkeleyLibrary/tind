require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module TindControlSubfield
        # check this value with old data later
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

          subfields = [Util.subfield(subname, sub_value)]
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

      end
    end
  end
end
