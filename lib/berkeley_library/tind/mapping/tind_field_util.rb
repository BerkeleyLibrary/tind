require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module TindFieldUtil

        # tag - regular alma field
        # referred tag - got tag from subfield6 value of a 880 field
        # nil rule caused by nil referred tag - eg. 880 subfild6 pass in a value in wrong format
        def rule(field)
          tag = origin_mapping_tag(field)
          return nil unless tag

          rules[Util.tag_symbol(tag)]
        end

        def tindfield_existed?(field, fields)
          return false unless field_has_rule?(field)

          field_rule = rule(field)
          mapping_to_tag = field_rule.pre_existed_tag
          return false unless mapping_to_tag

          map_to_tag_existed_in_fields?(field, fields, mapping_to_tag)
        end

        # To check TIND datafield and the specific subfield  from rule existed
        def tindfield_subfield_existed?(field, fields)
          return false unless field_has_rule?(field)

          field_rule = rule(field)
          return false unless pre_existed_tag_subfield_in_rule?(field_rule)

          tag_subfield = field_rule.pre_existed_tag_subfield
          mapping_to_tag = tag_subfield[0]
          return false unless map_to_tag_existed_in_fields?(field, fields, mapping_to_tag)

          existed_datafield = field_pre_existed(mapping_to_tag, field, fields)
          return false unless existed_datafield

          subfield_name = tag_subfield[1]
          existed_datafield[subfield_name] ? true : false
        end

        def field_880_on_subfield6_tag(tag, fields)
          datafield_on_tag(tag, fields) { |f| referred_tag(f) == tag }
        end

        def field_on_tag(tag, fields)
          datafield_on_tag(tag, fields) { |f| f.tag == tag }
        end

        private

        def field_has_rule?(field)
          field_rule = rule(field)
          return false unless field_rule

          true
        end

        def pre_existed_tag_subfield_in_rule?(rule)
          tag_subfield = rule.pre_existed_tag_subfield
          return false unless tag_subfield

          return false unless tag_subfield.length == 2

          true
        end

        def map_to_tag_existed_in_fields?(field, fields, mapping_to_tag)
          existed_tags = if is_880_field?(field)
                           tags_from_fields(fields) { |f| tag_from_880_subfield6(f) }
                         else
                           tags_from_fields(fields, &:tag)
                         end

          existed_tags.include? mapping_to_tag
        end

        # field, fields be both regular fields
        # or field, fields be both 880 fields
        # since a field may mapped to another one in TIND, mapping_to_tag is not always the same as field.tag
        def field_pre_existed(mapping_to_tag, field, fields)
          if is_880_field?(field)
            field_880_on_subfield6_tag(mapping_to_tag,
                                       fields)
          else
            field_on_tag(mapping_to_tag, fields)
          end
        end

        def datafield_on_tag(tag, fields)
          fields.find do |f|
            yield(f, tag)
          end
        end

        def tags_from_fields(fields, &block)
          fields.map(&block)
        end

        def tag_from_880_subfield6(field)
          field['6'].split('-')[0]
        end

      end

    end
  end
end
