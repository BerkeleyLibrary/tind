require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindMarc' do
        let(:tind_marc) { TindMarc.new(Config.test_record) }

        let(:normal_fields) { [Config.test_datafield('245'), Config.test_datafield('507')] }
        let(:normal_tindfield_tags) { ['245', '255'] }

        let(:with_pre_existed_fields) { [Config.test_datafield('245'), Config.test_datafield('264')] }
        let(:current_fields) { [Config.test_datafield('245'), Config.test_datafield('260')] }
        let(:with_pre_existed_tind_fields_tags) { ['245'] }

        let(:with_pre_existed_subfield_fields) { [Config.test_datafield('245'), Config.test_datafield('507')] }
        let(:current_with_pre_existed_subfield_fields) { [Config.test_datafield('245'), Config.test_datafield('255')] }
        let(:with_pre_existed_tind_subfield_fields_tags) { ['245'] }

        # mapped on pre_existed_field rule: "260"
        # mapped on pre_existed_subfield rule:  "255"
        let(:tindfield_tags) do
          %w[255 245 246 260 300 300 490 630 650
             700 710 903 041 269 255]
        end

        let(:tind_880_subfield6_tags) { ['245', '246', '260', '490', '700', '710', '255', nil, '500', '500', '500', '500'] }

        # mapped on pre_existed_field rule  => ''
        # mapped on pre_existed_subfield rule:  "880-255-09"
        # 880 datafields with '00' in subfield 6 come from field_catalog - 4 tindfields
        let(:tindfield_880_normal_tags) do
          %w[880-245-01 880-246-02 880-260-03 880-490-04
             880-700-06 880-710-07 880-255-09
             880-500-00 880-500-00 880-500-00 880-500-00]
        end

        it 'get a TIND record' do
          expect(tind_marc.tind_record).to be_a ::MARC::Record
        end

        it 'get all tindfields' do
          expect(tind_marc.tindfields.count).to eq 27 # 7 (normal tindfields) + 20 (880 tindfields)
        end

        it 'get normal tindfield tags' do
          expect(tind_marc.send(:tindfields_group).map(&:tag)).to eq tindfield_tags
          expect(tind_marc.send(:tindfields_group)[1]['a']).to eq 'Cang jie pian' # not "fake_255_a"
        end

        it 'get 880 tindfield tags' do
          expect(tind_marc.send(:tindfields_group_880).map { |f| tind_marc.origin_mapping_tag(f) }).to eq tind_880_subfield6_tags
        end

        it 'get 880 tindfield subfield6 values' do
          expect(tind_marc.fields_880_subfield6(tind_marc.send(:tindfields_group_880))).to eq tindfield_880_normal_tags
        end

        it 'get normal tindfields' do
          expect(tind_marc.send(:tindfields_from_normal, normal_fields).map(&:tag)).to eq normal_tindfield_tags
        end

        it 'get control tindfields' do
          expect(tind_marc.send(:tindfields_from_control, []).map(&:tag)).to eq ['041', '269']
        end

        it 'get tindfields with pre_existed field' do
          expect(tind_marc.send(:tindfields_with_pre_existed_field, with_pre_existed_fields, current_fields).map(&:tag)).to eq with_pre_existed_tind_fields_tags
        end

        it 'get tindfields with pre_existed_subfield' do
          expect(tind_marc.send(:tindfields_with_pre_existed_subfield, with_pre_existed_subfield_fields, current_with_pre_existed_subfield_fields).map(&:tag)).to eq normal_tindfield_tags
          expect(tind_marc.send(:tindfields_with_pre_existed_subfield, with_pre_existed_subfield_fields, current_with_pre_existed_subfield_fields)[1]['a']).to eq nil
        end

        # xit 'get add tindfields' do
        #   f = Config.test_datafield('507')
        #   expect(tind_marc.send(:add_tindfield, [], f)[0]['a']).to eq 'fake_507_a'
        #   # expect(tind_marc.send(:add_tindfield, [], f, excluding_subfield: true)[0]['a']).to eq nil
        # end

        # let(:add_control_fields) {
        #   field_001 = Config.test_datafield('001')
        #   # puts field_001.inspect
        #   outfields = []
        #   current_fields = [TindField.f('269', 'a', '2022')]
        #   tind_marc.send(:add_tindcontrolfield, outfields, field_001, current_fields)
        #   outfields
        # }

        # xit 'get adding control field' do
        #   field_001 = Config.test_datafield('001')
        #   outfields = []
        #   # current_fields = [TindField.f('269', 'a', '2022')]
        #   current_fields = []
        #   expect { tind_marc.send(:add_tindcontrolfield, outfields, field_001, current_fields) }.to change(outfields, :count).from(0).to(1)

        # end

      end
    end
  end
end
