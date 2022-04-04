# 902__$d derived from current date is added in this module

module BerkeleyLibrary
  module TIND
    module Mapping
      module AlmaBase
        include BerkeleyLibrary::Logging

        @collection_parameter_hash = {}
        @is_barcode = false
        @is_035_from_mms_id = false

        class << self
          attr_accessor :collection_parameter_hash
          attr_accessor :is_barcode
          attr_accessor :is_035_from_mms_id
        end

        # id can be:
        # 1) Alma mms id
        # 2) Oskicat No
        # 3) BarCode No
        # When alma record is nil or un-qualified, it returns nil
        # Input datafields - an array of record specific datafields:  for example, fft datafields, datafield 035 etc.
        def base_tind_record(id, datafields, alma_record = nil)
          marc_record = alma_record || alma_record_from(id)

          return nil unless marc_record?(marc_record, id)

          qualified?(marc_record, id) ? tind_record(id, marc_record, datafields) : nil
        end

        # This is mainly for testing purpose, each collection can have a function to save it's record
        def base_save(id, tind_record, file)
          return logger.warn("#{id} has no TIND record or not a qualified TIND record.") unless tind_record

          BerkeleyLibrary::TIND::MARC::XMLWriter.open(file) do |writer|
            writer.write(tind_record)
          end
        end

        private

        def marc_record?(alma_record, id)
          return true if alma_record

          logger.warn("#{id} has no Alma record.")
          false
        end

        def qualified?(alma_record, id)
          unless Util.qualified_alma_record?(alma_record)
            logger.warn("#{id} belong to a host bibliographic record which should not be uploaded to TIND.")
            return false
          end

          true
        end

        def alma_record_from(id)
          record_id = get_record_id(id)
          record_id.get_marc_record
        end

        def get_record_id(id)
          AlmaBase.is_barcode ? BerkeleyLibrary::Alma::BarCode.new(id) : BerkeleyLibrary::Alma::RecordId.parse(id)
        end

        def derived_tind_fields(mms_id)
          tind_fields = []
          tind_fields << TindField.f_902_d

          hash = AlmaBase.collection_parameter_hash
          tind_fields.concat ExternalTindField.tind_fields_from_collection_information(hash)

          tind_fields.concat ExternalTindField.tind_mms_id_fields(mms_id)

          f_035 = add_f_035(mms_id, hash)
          tind_fields << f_035 if f_035

          tind_fields
        end

        def tind_record(id, marc_record, datafields)
          tindmarc = TindMarc.new(marc_record)
          # get all derived tind_fields: 1) from collection information; 2) from id
          mms_id = tindmarc.field_catalog.mms_id
          logger.warn("#{id} has no Control Field 001") unless mms_id

          tind_fields = derived_tind_fields(mms_id)
          # add inputted record specific datafields
          tind_fields.concat datafields
          tindmarc.tind_external_datafields = tind_fields

          # creete a tind marc record
          tindmarc.tind_record
        end

        def add_f_035(mms_id, hash)
          return nil unless mms_id && AlmaBase.is_035_from_mms_id

          val_980 = hash['980'][0].strip
          TindField.f_035_from_alma_id(mms_id, val_980)
        end

      end
    end
  end
end
