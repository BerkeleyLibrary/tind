module BerkeleyLibrary
  module TIND
    module Mapping
      # TODO: ADD CSV VALIDATION, WHEN NEED ADD A NEW MAPPING CSV FILE
      # 1. not empty row
      # 2. a subfield name can appear in either normal mapping or combine mapping, not both
      # 3. single map has the same amount of from names and to names
      # 4. Combine mappping should have tree columns, validate more?
      # 5. Combine from_subfield, to_subfield should have values, no empty
      # 6. Tag from row[:map_if_no_this_tag_subfield_existed]), row[:map_if_no_this_tag_existed] # This tag should be the same as destination tag
      # 7. In single map csv, one row cannot have both "map_if_no_this_tag_existed" (245) and ":map_if_no_this_tag_subfield_existed"
      #      (245__b) because tag in these two column are  identical
      # 8. csv file validation - a row should have coulumns:  tag origin and destintation ? single rule
      # 9. Validating these column names
      # 10. csv file validation - a row should have coulumns:  tag origin and destintation ? single rule
      # 11. validating headers
      # 12.  Formats for some of the columns

      class SingleRule
        include Util
        attr_reader :tag_origin
        attr_reader :tag_destination
        attr_reader :indicator
        attr_reader :pre_existed_tag
        attr_reader :pre_existed_tag_subfield
        attr_reader :single_rule_hash
        attr_reader :single_rule_subfield_excluded_hash
        attr_reader :combined_rules
        attr_reader :subfields_order

        def initialize(row)
          @tag_origin = row[:tag_origin]
          @tag_destination = row[:tag_destination]
          @indicator = Util.indicator(row[:new_indecator])
          @pre_existed_tag = row[:map_if_no_this_tag_existed]
          @pre_existed_tag_subfield = existed_tag_subfield(row[:map_if_no_this_tag_subfield_existed]) # This tag should be the same as destination tag
          @single_rule_hash = single_map_dic(row[:subfield_single_from], row[:subfield_single_to])
          @single_rule_subfield_excluded_hash = single_map_subfield_excluded_dic
          @combined_rules = rules_with_same_subfield_name(row)
          @subfields_order = order(row[:order])
        end

        # 1. Return an array of combined rules, an item in the array
        #    is an array of rules which have the same 'to subfield name'
        # 2. An example: [[["a,b,c,d", "b", "--"],["o,p,q", "b", ""]],[["x,y,z", "a", "--"]]]
        def rules_with_same_subfield_name(row)
          rules = all_combined_rules(row)
          identical_to_subfield_names = unique_tosubfield_names(rules)
          identical_to_subfield_names.each_with_object([]) do |name, result|
            result << rules_with_sametosubfield(name, rules)
          end
        end

        private

        def order(str)
          str.nil? ? nil : str.split(',')
        end


        # return an array of tag and subfield name, example '255__a' => ['255','a']
        def existed_tag_subfield(str)
          str.nil? ? nil : str.split('__')
        end

        # list identical 'to subfield name's from combined mapping rules
        # (an example rule ['a,b,c', 'b', ' -- '])
        def unique_tosubfield_names(rules)
          names = rules.map { |rule| rule[1] }
          names.uniq
        end

        # numbers of combined rules
        def combined_rule_counts(row)
          headers = row.headers
          headers.select { |h| h.to_s.include? 'subfield_combined_from_' }.count
        end

        # Three coulumns 'subfield_combined_from_*','subfield_combined_to_*','symbol_*'
        # define a combined mapping rule
        def combined_rule(row, i)
          from_subfield = row["subfield_combined_from_#{i}".to_sym]
          to_subfield = row["subfield_combined_to_#{i}".to_sym]
          s = row["symbol_#{i}".to_sym]
          from_subfield.nil? || to_subfield.nil? ? nil : [from_subfield, to_subfield, s] # add validation rule , such as not empty later
        end

        def all_combined_rules(row)
          rules = []
          n = combined_rule_counts(row)
          (1..n).each do |i|
            rule = combined_rule(row, i)
            rules << rule if rule
          end
          rules
        end

        # list all combined rules with the same 'to subfield name'
        def rules_with_sametosubfield(name, rules)
          rules.each_with_object([]) do |rule, result|
            result << rule if rule[1] == name
          end
        end

        # Define a hash for single map rules, key is 'from subfield name',
        # value is 'to subfield name'
        def single_map_dic(str_from, str_to)
          dic = {}
          if  should_single_map?(str_from, str_to)
            arr_from = str_from.strip.split(',')
            arr_to = str_to.strip.split(',')
            arr_from.each_with_index { |from_name, i| dic[from_name.to_s] = arr_to[i].to_s }
          end
          dic
        end

        # Hash removed the excluding subfield
        def single_map_subfield_excluded_dic
          dic = @single_rule_hash
          return dic unless excluding_subfield?

          excluding_subfield_name = @pre_existed_tag_subfield[1].to_s
          dic.delete(excluding_subfield_name) if dic.key? excluding_subfield_name
          dic
        end

        # Check excluding subfield
        def excluding_subfield?
          return false unless @pre_existed_tag_subfield
          return false unless @pre_existed_tag_subfield[1]

          true
        end

        # add this to validation
        def should_single_map?(str_from, str_to)
          return false unless str_from && str_to

          arr_from = str_from.split(',')
          arr_to = str_to.split(',')
          return false unless arr_from.count == arr_to.count

          true
        end

      end

    end
  end
end
