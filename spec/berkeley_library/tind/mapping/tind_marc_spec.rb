require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindMarc' do

        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }

        let(:tind_marc) { TindMarc.new(qualified_alm_record) }

        let(:normal_fields) { [qualified_alma_obj.field('245'), qualified_alma_obj.field('507')] }
        let(:normal_tindfield_tags) { ['245', '255'] }

        let(:with_pre_existed_fields) { [qualified_alma_obj.field('245'), qualified_alma_obj.field('264')] }
        let(:current_fields) { [qualified_alma_obj.field('245'), qualified_alma_obj.field('260')] }
        let(:with_pre_existed_tind_fields_tags) { ['245'] }

        let(:with_pre_existed_subfield_fields) { [qualified_alma_obj.field('245'), qualified_alma_obj.field('507')] }
        let(:current_with_pre_existed_subfield_fields) { [qualified_alma_obj.field('245'), qualified_alma_obj.field('255')] }
        let(:with_pre_existed_tind_subfield_fields_tags) { ['245'] }

        # mapped on pre_existed_field rule: "260"
        # mapped on pre_existed_subfield rule:  "255"
        let(:tindfield_tags) do
          %w[255 245 246 260 300 300 490 630 650
             700 710 903 041 269 255]
        end

        let(:tind_880_subfield6_tags) { ['245', '246', '260', '490', '650', '700', '710', '255', nil, '500', '500', '500', '500'] }

        # mapped on pre_existed_field rule  => ''
        # mapped on pre_existed_subfield rule:  "880-255-09"
        # 880 datafields with '00' in subfield 6 come from field_catalog - 4 tindfields
        let(:tindfield_880_normal_tags) do
          %w[880-245-01 880-246-02 880-260-03 880-490-04 880-650-05
             880-700-06 880-710-07 880-255-09
             880-500-00 880-500-00 880-500-00 880-500-00]
        end

        context '# From public methods: ' do
          it 'get a TIND record' do
            expect(tind_marc.tind_record).to be_a ::MARC::Record
          end

          it 'get all tindfields' do
            expect(tind_marc.tindfields.count).to eq 28 # 7 (normal tindfields) + 21 (880 tindfields)
          end
        end

        context '# From private methods: ' do

          it 'get normal tindfield tags' do
            expect(tind_marc.send(:tindfields_group).map(&:tag)).to eq tindfield_tags
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
          end

        end

      end
    end
  end
end
