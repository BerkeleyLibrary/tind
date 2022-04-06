require 'berkeley_library/tind/mapping/tind_subfield_util'
require 'berkeley_library/tind/mapping/misc'
require 'berkeley_library/tind/mapping/field_catalog_util'
require 'berkeley_library/tind/mapping/match_tind_field'

module BerkeleyLibrary
  module TIND
    module Mapping

      class DataFieldsCatalog
        include Misc
        include TindSubfieldUtil
        include CsvMapper
        include Util
        include AdditionalDatafieldProcess
        include FieldCatalogUtil
        include MatchTindField
        include BerkeleyLibrary::Logging

        attr_reader :control_fields
        attr_reader :data_fields_group
        attr_reader :data_fields_880_group
        attr_reader :data_fields_880_00
        attr_reader :mms_id

        def initialize(record)
          @control_fields = []
          @data_fields_group = []
          @data_fields_880_group = []
          @data_fields_880_00 = []
          @mms_id = ''

          @data_fields = []
          @data_fields_880 = []
          @alma_field_tags = []

          init(record)
        end

        def init(record)
          prepare_catalog(record)
          @data_fields_group = prepare_group(@data_fields)
          @data_fields_880_group = prepare_group(@data_fields_880)
          @mms_id = alma_mms_id
        end

        def prepare_catalog(record)
          clean_fields = clean_subfields(record.fields)
          check_abnormal_formated_subfield6(clean_fields)
          allocate_fields(clean_fields)
          remove_fields_with_subject_fast
        end

        def remove_fields_with_subject_fast
          @data_fields = exluding_fields_with_fast_subject(@data_fields)
          @data_fields_880 = exluding_fields_with_fast_subject(@data_fields_880)
        end

        private

        def allocate_fields(fields)
          fields.each do |f|
            next if added_control_field?(f)
            next if added_880_field?(f)

            tag = f.tag
            next unless (found_in_mapper? tag) && (no_pre_existed_field? tag)

            @data_fields << f
            @alma_field_tags << f.tag
          end
        end

        # 880 field with a subfield6 including a tag belong to origin tags defined in csv file
        def qualified_880_field?(f)
          return false unless referred_tag(f)

          found_in_mapper?(referred_tag(f))
        end

        def added_control_field?(f)
          return false unless ::MARC::ControlField.control_tag?(f.tag)

          @control_fields << f
          true
        end

        def added_880_field?(f)
          return false unless f.tag == '880'

          # adding 880 datafield with "non-subfield6" to "00" group for keeping this record in TIND
          # with log information, to let users correcting or removing this datafield from TIND record
          @data_fields_880_00 << f unless valid_subfield6?(f)

          if qualified_880_field?(f)
            subfield6_endwith_00?(f) ? @data_fields_880_00 << f : @data_fields_880 << f
          end

          true
        end

        def valid_subfield6?(f)
          return true if subfield6?(f)

          logger.warn("880 field has no subfield 6 #{f.inspect}")

          false
        end

        # Is the origin_tag of a field has related from_tag in csv file?
        def found_in_mapper?(tag)
          from_tags.include? tag
        end

        # If tag is listed in csv_mapper.one_occurrence_tags
        # Check pre_existed field of this tag
        # make sure to keep the first datafield for an one_occurrence_tag defined in csv mapping file
        # def no_pre_existed_field?(tag)
        #   # no one-occurrence defined in csv
        #   return true unless one_occurrence_tags.include? tag

        #   # Checking the exsisting regular fields include the one-occurrence field defined in the csv
        #   return false if @alma_field_tags.compact.include? tag

        #   true
        # end

        def no_pre_existed_field?(tag)
          # no one-occurrence defined in csv
          return true unless one_occurrence_tags.include? tag

           # Checking the exsisting regular fields include the one-occurrence field defined in the csv
          !(@alma_field_tags.compact.include? tag)
        end

        def alma_mms_id
          f_001 = @control_fields.find { |f| f if f.tag == '001' }
          return nil unless f_001

          f_001.value
        end

      end
    end
  end
end
