require 'marc'
require 'berkeley_library/tind/mapping/util'
require 'berkeley_library/tind/mapping/tind_subfield_util'

# 1. datafield could be a regular alma field
# 1) data_fields_normal - using  @single_rule_hash from SingleRule
# 2) data_fields_with_pre_existed_field - using  @single_rule_hash from SingleRule
# 3) data_fields_with_pre_existed_subfield  - using   @single_rule_subfield_excluded_hash  from SingleRule

# 2. data field could be an 880 alma field , below types are definded based on the tag from subfield6
# 1) data_fields_normal - using  @single_rule_hash from SingleRule
# 2) data_fields_with_pre_existed_field - using  @single_rule_hash from SingleRule
# 3) data_fields_with_pre_existed_subfield  - using   @single_rule_subfield_excluded_hash from SingleRule

# 3. map_to_tag, indicator are from mapping rule for output tindfield
# 4. subfileds are re-mapped, or combined, used as subfields for  output tindfield

module BerkeleyLibrary
  module TIND
    module Mapping

      class TindFieldFromSingleMap
        include CsvMapper
        include Util
        include TindSubfieldUtil
        include Misc

        # excluding_subfield = false: mapping by rule.single_rule_hash
        # excluding_subfield = true: mapping by rule.single_rule_subfield_excluded_hash
        def initialize(datafield, excluding_subfield)
          @from_datafield = datafield
          @excluding_subfield = excluding_subfield

          @is_880_field = is_880_field?(datafield)

          @mapping_rule = rule
          @map_to_tag = nil
          @indicator = nil
          @single_mapping = nil
          @ready_to_mapping = ready_to_mapping?

          @to_subfields = all_subfields
        end

        def to_datafield
          return nil unless mapped?

          tindfield = Util.datafield(@map_to_tag, @indicator, @to_subfields)
          @is_880_field ? reversed_880_field(tindfield) : tindfield
        end

        private

        # A referred tag from 880 subfield6 may not have a rule
        # For example: 880 subfild6 pass in a value in wrong format
        # In above case, rule is nil
        # Get mapping parameters from rule when having a rule
        def ready_to_mapping?
          return false unless @mapping_rule

          @map_to_tag = @mapping_rule.tag_destination
          @indicator =  @mapping_rule.indicator
          @single_mapping = @excluding_subfield ? @mapping_rule.single_rule_subfield_excluded_hash : @mapping_rule.single_rule_hash

          # puts  @single_mapping.inspect  if @from_datafield.tag == '507'

          return false unless @map_to_tag && @indicator && !@single_mapping.empty?

          true
        end

        def mapped?
          !@to_subfields.empty?
        end

        # tag - regular alma field
        # referred tag - got tag from subfield6 value of a 880 field
        # nil rule caused by nil referred tag - eg. 880 subfild6 pass in a value in wrong format
        def rule
          tag = origin_mapping_tag(@from_datafield)
          return nil unless tag

          rules[Util.tag_symbol(tag)]
        end

        def all_subfields
          @ready_to_mapping ? (subfields_from_single_map + subfields_from_combined_map) : []
        end

        # 1.subfields mapped with single rule, mapping one subfield to another subfield
        # 2. one subfield is mapped to one subfield
        # 3. When mutiple subfields with the same name found in an orignal field,
        # they will be mapped one by one
        def subfields_from_single_map
          return [] if @single_mapping.empty?

          mapped_subfields = []
          @single_mapping.each do |from, to|
            subfields = subfields_from_to(@from_datafield, from, to)
            mapped_subfields.concat(subfields)
          end
          mapped_subfields
        end

        # return all subfields mapped with diferent combined rules - different destination subfield names
        # mapped with all combined rules, exmaple: [[["a,b,c,d", "b", "--"],["o,p,q", "b", ""]],[["x,y,z", "a", "--"]]]
        # mapping using above example rules will return two subfield: $b, $a
        def subfields_from_combined_map
          all_rules = @mapping_rule.combined_rules
          return [] if all_rules.empty?

          mapped_subfields = []
          all_rules.each do |rules|
            subfield = subfield_on_same_tosubfieldname(rules)
            mapped_subfields.push(subfield) if subfield
          end
          mapped_subfields
        end

        # create one subfield with a desintaion subfield name
        # input array of rules example: [["a,b,c,d", "b", "--"],["o,p,q", "b", ""]] -- all rules with the same destination subfield name "b"
        # get a subfield$b with a concatenated value
        def subfield_on_same_tosubfieldname(rules)
          return nil if rules.empty?

          val = subfield_value_on_rules(rules)
          return nil if val.strip.empty?

          subfield_name_to = rules[0][1]
          Util.subfield(subfield_name_to, Util.remove_extra_symbol(rules, val))
        end

        # input an array of rules, example: [["a,b,c,d", "b", "--"],["o,p,q", "b", ""]]
        # Theese rules have the same destination subfield name, for example "b" in above example
        # get a value concatenated with values mapped using different rules
        def subfield_value_on_rules(rules)
          val = ''
          rules.each { |rule| val << subfield_value_on_rule(rule) }
          val
        end

        # input a rule (for example ["a,b,c,d", "b", "--"]),
        # get a combined value of subfield a,b,c,d concatenated by " -- " as above example
        # One subfield names may occurs mutiple times in a an orignal field
        def subfield_value_on_rule(rule)
          subfield_names_from = rule[0].strip.split(',')
          symbol = Util.concatenation_symbol(rule[2])
          val = ''
          subfield_names_from.each do |subfield_name|
            sub_val = combined_subfield_value(@from_datafield, subfield_name, symbol)
            val << sub_val
          end
          val
        end

        # 880 datafield: reverse tag from 'to_tag' defined mapping rule to '880'
        def reversed_880_field(f)
          update_datafield6(f)
          f.tag = '880'
          f
        end

        # update subfield6 tag with destination tag from the rule
        # since an origin tag may have been mapped a different tag - destination tag
        def update_datafield6(f) # need test
          f['6'].sub!(@mapping_rule.tag_origin, @mapping_rule.tag_destination)
        end

      end
    end
  end
end
