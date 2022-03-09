require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindFieldUtil' do
        let(:tind_marc) { TindMarc.new(Config.test_record) }

        let(:normal_fields_group) { tind_marc.field_catalog.data_fields_group[:normal] }
        let(:field_normal) { Config.test_datafield('245') }
        let(:field_pre_existed_field) { Config.test_datafield('264') } # 264 has pre_existed field defined in csv file
        let(:field_pre_existed_field_and_subfield) { Config.test_datafield('507') } # 507 has pre_existed_field_subfield defined in csv file

        it 'get a rule on datafield' do
          expect(tind_marc.rule(field_normal).class).to eq BerkeleyLibrary::TIND::Mapping::SingleRule
        end

        it 'tindfield found existing list of tindfields' do
          expect(tind_marc.tindfield_existed?(field_pre_existed_field, normal_fields_group)).to eq true
        end

        it 'tindfield not found existing list of tindfields' do
          expect(tind_marc.tindfield_existed?(field_normal, normal_fields_group)).to eq false
        end

        # fake 255$a existing in the record.xml
        it 'tindfield subfield found in existing list of tindfields' do
          expect(tind_marc.tindfield_subfield_existed?(field_pre_existed_field_and_subfield, normal_fields_group)).to eq true
        end

        it 'tindfield subfield not found existing list of tindfields' do
          expect(tind_marc.tindfield_subfield_existed?(field_normal, normal_fields_group)).to eq false
        end
      end
    end

  end
end
