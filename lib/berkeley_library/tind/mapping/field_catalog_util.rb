# 1. Combine repeated fields
# 2. Sort subfields
# 3. Remove characters pre_defined
module BerkeleyLibrary
  module TIND
    module Mapping
      module FieldCatalogUtil

        def fields_no_subject_fast(regular_fields)
          tags_with_subject_fast = []
          fields = []
          regular_fields.each do |f|
            exclude_field?(f) ? tags_with_subject_fast << f.tag : fields << f
          end
          [tags_with_subject_fast, fields]
        end

        def fields_880_no_subject_fast(tags, fields_880)
          fields_880.reject { |f| exclude_880_field?(f, tags) }
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

      end
    end
  end
end
