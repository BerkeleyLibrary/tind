module BerkeleyLibrary
  module TIND
    module Mapping
      module FieldCatalogUtil

        # Excluding fields: subfield2 = 'fast' and tag or refered tag(880 fields) started with '6':
        def exluding_fields_with_fast_subject(fields)
          fields.reject { |f| excluding_field?(f) }
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

        def excluding_field?(f)
          return false unless field_6xx?(f)
          return false unless subfield2_fast(f)

          true
        end

        # Both regular and 880 field: tag or refered tag started with '6'
        def field_6xx?(f)
          tag = origin_mapping_tag(f)
          tag =~ /^6\d{2}$/
        end

        def subfield2_fast(f)
          subject = f['2']
          return false unless subject

          subject.downcase == 'fast'
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
