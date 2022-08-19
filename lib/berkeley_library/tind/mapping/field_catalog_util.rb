require 'berkeley_library/tind/mapping/alma_base'

module BerkeleyLibrary
  module TIND
    module Mapping
      module FieldCatalogUtil
        include AlmaBase

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

            assign_field(rule, f, datafields_hash)
          end

          datafields_hash
        end

        # Defining a list of fields from Alma to be mapped to TIND fields based on
        # collection configuration:
        # 1) BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags
        # 2) BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags
        def fields_to_map(fields)
          including_defined = !BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags.empty?
          excluding_defined = !BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags.empty?
          return [] if including_defined && excluding_defined # not allow to define both including and excluding tags
          return fields unless including_defined || excluding_defined # Neither including nor excluding tags are defined
          return fields_included(fields) if including_defined # including tags defined
          return fields_exclued(fields) if excluding_defined  # excluding tags defined
        end

        private

        def fields_included(fields)
          fields.select { |f| inclduing?(f) }
        end

        def inclduing?(f)
          return true if %w[001 008].include? f.tag # always keeping 001, 008 field since it include almid

          tag = origin_mapping_tag(f)
          BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags.include? tag
        end

        def fields_exclued(fields)
          new_fields = []
          exclude_tags = BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags
          fields.each do |f|
            tag = tag(f, exclude_tags)
            new_fields << f unless exclude_tags.include? tag
          end
          new_fields
        end

        # 1. exluding tags have '880' :  all 880 fields will be excluded
        # 2. excluding tags have no '880', then excluding 880 fields whoses refered tag located in excluding tags
        def tag(field, exclude_tags)
          return field.tag if exclude_tags.include? '880' #  Case: excluding all 880 fields

          origin_mapping_tag(field)
        end

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
        def assign_field(rule, f, datafields_hash)
          if rule.pre_existed_tag then datafields_hash[:pre_tag] << f
          elsif rule.pre_existed_tag_subfield then datafields_hash[:pre_tag_subfield] << f
          else
            datafields_hash[:normal] << f
          end
        end

      end
    end
  end
end
