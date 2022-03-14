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
        let(:fields_880_group) { tind_marc.field_catalog.data_fields_880_group[:normal] }
        let(:field_880_245) { Config.test_datafield_880('245-01/$1') }

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

        it 'find an 880 field, subfield6 including tag 245' do
          expect(tind_marc.field_880_on_subfield6_tag('245', fields_880_group)['6']).to eq '245-01/$1'
        end

        describe '# field_pre_existed' do
          it 'find pre_existed 880 field' do
            # def field_pre_existed(mapping_to_tag, field, fields)
            expect(tind_marc.send(:field_pre_existed, '245', field_880_245, fields_880_group)['6']).to eq '245-01/$1'
          end

          it 'find no pre_existed 880 field' do
            expect(tind_marc.send(:field_pre_existed, '247', field_880_245, fields_880_group)).to eq nil
          end

          it 'find pre_existed regular field' do
            expect(tind_marc.send(:field_pre_existed, '245', field_normal, normal_fields_group).tag).to eq '245'
          end

          it 'find no pre_existed regular field' do
            expect(tind_marc.send(:field_pre_existed, '299', field_normal, normal_fields_group)).to eq nil
          end

        end

      end
    end

  end
end
