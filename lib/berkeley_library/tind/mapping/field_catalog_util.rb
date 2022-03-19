module BerkeleyLibrary
  module TIND
    module Mapping
      module FieldCatalogUtil

        # Excluding regular fields with subject = 'fast' (subfield2 = 'fast'), return:
        # 1) a list of tags of those excluded fields
        # 2) a list of fields after excluding those fields with subfield2 = 'fast'
        def fields_no_subject_fast(regular_fields)
          tags_with_subject_fast = []
          fields = []
          regular_fields.each do |f|
            exclude_field?(f) ? tags_with_subject_fast << f.tag : fields << f
          end
          [tags_with_subject_fast, fields]
        end

        # Excluding 880 fields with subfield6 has a tag, it's related regular field has been excluded
        # due to subject = 'fast'
        # Inupt: tags = tag list of those excluded regular fields, fields_880 = all the 880 fields
        def fields_880_no_subject_fast(tags, fields_880)
          fields_880.reject { |f| exclude_880_field?(f, tags) }
        end

        def prepare_group(from_fields)
          datafields_hash = { normal: [], pre_tag: [], pre_tag_subfield: [] }
          from_fields.each do |f|
            # a regular field tag, or a tag value from 880 field captured from subfield6
            tag = origin_mapping_tag(f)
            next unless tag

            rule = rules[Util.tag_symbol(tag)]
            assing_field(rule, f, datafields_hash)
          end

          datafields_hash
        end

        private

        def exclude_field?(f)
          return false unless field_6xx?(f)
          return false unless subfield2_fast(f)

          true
        end

        def field_6xx?(f)
          tag = f.tag.to_s
          tag =~ /^6\d{2}$/
        end

        def subfield2_fast(f)
          subject = f['2']
          return false unless subject

          subject.downcase == 'fast'
        end

        def exclude_880_field?(f, tags)
          return false if subfield6_endwith_00?(f)

          tag = referred_tag(f)
          tags.include? tag
        end

        # f is either from field whose tag having a match in csv mapping file - 'from tag' column
        def assing_field(rule, f, datafields_hash)
          if rule.pre_existed_tag then datafields_hash[:pre_tag] << f
          elsif rule.pre_existed_tag_subfield then datafields_hash[:pre_tag_subfield] << f
          else  datafields_hash[:normal] << f
          end
        end

      end
    end
  end
end
