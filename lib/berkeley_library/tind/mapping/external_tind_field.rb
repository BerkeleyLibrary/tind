require 'marc'

# Derived fields from this module
# 1) From collection information:
#  336__$a
#  852__$c
#  982__$a,b
#  991__$a
# 2) From mms_id
# 901__$m
# 85641$u,y

module BerkeleyLibrary
  module TIND
    module Mapping
      module ExternalTindField
        class << self
          include BerkeleyLibrary::Logging

          def tind_fields_from_collection_information(hash)
            raise ArgumentError, 'Collection parameters are incorrect.' unless valid_collection_hash?(hash)

            collection_fields(hash)
          end

          def tind_mms_id_fields(mms_id)
            raise ArgumentError, 'mms_id is nil' unless mms_id

            mms_id_fields(mms_id)
          end

          private

          def collection_fields(hash)
            fields = []
            hash.each_key do |tag|
              tindfield = tindfield_on_tag(tag, hash)
              fields << tindfield if tindfield
            end

            fields
          end

          def mms_id_fields(mms_id)
            fields = []
            fields << tind_field_901_m(mms_id)
            fields << tind_field_856_4_1(mms_id)
          end

          def tind_field_901_m(alma_id)
            ::MARC::DataField.new('901', ' ', ' ', ['m', alma_id])
          end

          def tind_field_856_4_1(alma_id)
            u = "https://search.library.berkeley.edu/discovery/fulldisplay?context=L&vid=01UCS_BER:UCB&docid=alma#{alma_id}"
            y = 'View library catalog record.'
            subfield1 = Util.subfield('u', u)
            subfield2 = Util.subfield('y', y)

            ::MARC::DataField.new('856', '4', '1', subfield1, subfield2)
          end

          def tindfield_on_tag(tag, hash)
            subfield_names = Config.collection_subfield_names[tag]
            subfield_values = hash[tag]
            return nil if subfield_values.empty?

            subfields = tind_subfields(subfield_values, subfield_names)
            Util.datafield(tag, [' ', ' '], subfields)
          end

          def tind_subfields(subfield_values, subfield_names)
            subfields = []
            subfield_values.each_with_index do |value, i|
              name = subfield_names[i]
              subfield = Util.subfield(name, value.strip)
              subfields << subfield
            end
            subfields
          end

          def valid_collection_hash?(hash)
            return false unless valid_item?(hash, '336', 1) &&
            valid_item?(hash, '852', 1) && valid_item?(hash, '980', 1) && valid_item?(hash, '982', 2) && valid_991?(hash)

            true
          end

          def valid_item?(hash, key, num)
            (hash.key? key) && (hash[key].length == num)
          end

          def valid_991?(hash)
            cout = hash['991'].length
            [0, 1].include?(cout)
          end

        end
      end
    end

  end
end
