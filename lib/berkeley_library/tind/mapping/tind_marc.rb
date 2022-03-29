require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      class TindMarc
        include CsvMapper
        include Util
        include TindSubfieldUtil
        include Misc
        include TindFieldUtil
        include AdditionalDatafieldProcess
        include BerkeleyLibrary::Logging
        include MatchTindField

        attr_accessor :source_marc_record
        attr_writer :tind_external_datafields
        attr_reader :field_catalog
        attr_reader :mms_id

        # input an alma record
        def initialize(record)
          @source_marc_record = record
          @field_catalog = DataFieldsCatalog.new(@source_marc_record)
          @tind_external_datafields = []
        end

        # return mapped tind datafields
        # keep the order of different mapping
        def tindfields
          fields = []
          fields.concat tindfields_group
          fields.concat tindfields_group_880
          fields
        end

        # return a TIND Marc record
        # add external datafields
        # flag to do additional TIND datafield process before generating a TIND Marc record
        def tind_record
          fields = tindfields
          fields.concat @tind_external_datafields
          more_process(fields)
          record = ::MARC::Record.new
          fields.each { |f| record.append(f) }
          record
        end

        private

        # return mapped tind datafields
        # keep the order of different mapping
        def tindfields_group
          fields_from_normal = tindfields_from_normal(@field_catalog.data_fields_group[:normal])
          fields_from_leader = TindFieldFromLeader.new(@source_marc_record).to_datafields

          temp_fields = fields_from_normal.concat fields_from_leader
          temp_fields.concat tindfields_from_control(temp_fields)
          temp_fields.concat tindfields_with_pre_existed_field(@field_catalog.data_fields_group[:pre_tag], temp_fields)
          temp_fields.concat tindfields_with_pre_existed_subfield(@field_catalog.data_fields_group[:pre_tag_subfield], temp_fields)

          temp_fields
        end

        # return mapped tind 880 datafields
        # keep the order of different mapping
        def tindfields_group_880
          fields = []
          fields.concat tindfields_from_normal(@field_catalog.data_fields_880_group[:normal])
          fields.concat tindfields_with_pre_existed_field(@field_catalog.data_fields_880_group[:pre_tag], fields)
          fields.concat tindfields_with_pre_existed_subfield(@field_catalog.data_fields_880_group[:pre_tag_subfield], fields)
          fields.concat @field_catalog.data_fields_880_00
          fields
        end

        # # Return TIND datafields mapped in a normal way
        # # Normal way mapping: one regular datafield is mapped one TIND datafield
        def tindfields_from_normal(alma_fields)
          new_fls = []
          alma_fields.each do |f|
            add_tindfield(new_fls, f, excluding_subfield: false)
          end
          new_fls
        end

        # Return TIND datafield mapped from a control datafield
        # One control datafield could be mapped to multiple TIND datafields
        def tindfields_from_control(currentfields)
          new_fls = []
          @field_catalog.control_fields.each do |f|
            add_tindcontrolfield(new_fls, f, currentfields)
          end
          new_fls
        end

        # Return TIND datafields if no pre_existed field
        def tindfields_with_pre_existed_field(alma_fields, currentfields)
          new_fls = []
          alma_fields.each do |f|
            add_tindfield(new_fls, f, excluding_subfield: false) unless tindfield_existed?(f, currentfields)
          end
          new_fls
        end

        # Return TIND datafields considering excluding pre_existing subfields
        def tindfields_with_pre_existed_subfield(alma_fields, currentfields)
          new_fls = []
          alma_fields.each do |f|
            excluding_subfield = tindfield_subfield_existed?(f, currentfields)
            add_tindfield(new_fls, f, excluding_subfield: excluding_subfield)
          end
          new_fls
        end

        def add_tindfield(fls, f, excluding_subfield: false)
          tindfield = TindFieldFromSingleMap.new(f, excluding_subfield).to_datafield
          fls << tindfield if tindfield
        end

        def add_tindcontrolfield(fls, f, currentfields)
          fls.concat TindFieldFromMultipleMap.new(f, currentfields).to_datafields
        end

        # Additional processes - run in a sequence
        def more_process(fields)
          remove_repeats(fields)
          clean_subfields(fields)
          un_matched_fields_880(fields, @field_catalog.mms_id)
        end

      end
    end
  end
end
