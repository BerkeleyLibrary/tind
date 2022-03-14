require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module ExternalTindField
        class << self
          include BerkeleyLibrary::Logging

          # def tind_fields_from_collection_information(hash)
          #   fields = []
          #   if valid_collection_hash?(hash)
          #     hash.each_key do |tag|
          #       tindfield = tindfield_on_tag(tag, hash)
          #       fields << tindfield if tindfield
          #     end
          #   else
          #     logger.warn('Collection parameters are incorrect, please check.')
          #   end
          #   fields
          # end

          # def tind_fields_from_alma_id(mms_id, alma_id)
          #   fields = []
          #   if mms_id
          #     fields << tind_field_901_m(mms_id)
          #     fields << tind_field_856_4_1(mms_id)
          #   else
          #     logger.warn("#{alma_id} has no Control Field 001")
          #   end
          #   fields
          # end

          def tind_fields_from_collection_information(hash)
            return collection_fields(hash) if valid_collection_hash?(hash)

            logger.warn('Collection parameters are incorrect, please check.')
            []
          end

          def tind_fields_from_alma_id(mms_id, alma_id)
            return mms_id_fields(mms_id) if mms_id

            logger.warn("#{alma_id} has no Control Field 001")
            []
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
              subfield = Util.subfield(name, value)
              subfields << subfield
            end
            subfields
          end

          # def valid_collection_hash?(hash)
          #   return false unless valid_336(hash) &&
          #   valid_852(hash) && valid_980(hash) && valid_982(hash) && valid_991(hash)

          #   true
          # end

          def valid_collection_hash?(hash)
            return false unless valid_item?(hash, '336', 1) &&
            valid_item?(hash, '852', 1) && valid_item?(hash, '980', 1) && valid_item?(hash, '982', 2) && valid_991(hash)

            true
          end

          def valid_item?(hash, key, num)
            (hash.key? key) && (hash[key].length == num)
          end

          # def valid_336(hash)
          #   key = '336'
          #   num = 1
          #   valid_item?(hash, key, num)

          # end

          # def valid_852(hash)
          #   key = '852'
          #   num = 1
          #   valid_item?(hash, key, num)
          # end

          # def valid_980(hash)
          #   hash['980'].length == 1
          # end

          # def valid_982(hash)
          #   hash['982'].length == 2
          # end

          def valid_991(hash)
            cout = hash['991'].length
            [0, 1].include?(cout)
          end

        end
      end
    end

  end
end
