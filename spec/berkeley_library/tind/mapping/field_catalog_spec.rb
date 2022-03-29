require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      # 14 tags match origin tags defined in csv file
      # ["245", "246", "260", "300", "300", "490", "630", "650", "650", "700", "710", '264', '264','507']
      describe 'DataFieldsCatalog' do
        let(:datafields_catalog) { DataFieldsCatalog.new(Config.test_record) }
        let(:mms_id) { '991046494559706532' }

        let(:alma_tags) { %w[255 245 246 260 300 300 490 630 650 700 710] }
        let(:alma_tags_with_pre_existed_tag) { ['264'] }
        let(:alma_tags_with_pre_existed_tag_subfield) { ['507'] }

        let(:f880_subfield6) { %w[880-245-01 880-246-02 880-260-03 880-490-04 880-650-05 880-700-06 880-710-07] }
        let(:f880_subfield6_with_pre_existed_tag) { [] }
        let(:f880_subfield6_with_pre_existed_tag_subfield) { ['880-507-09'] }

        # 880 datafield with "880-510-00" should not be includede
        let(:f880_sbufield6_with_00) { %w[880-500-00 880-500-00 880-500-00 880-500-00] }
        let(:not_f880_sbufield6_with_00) { '880-510-00' }

        it 'get control_fields' do
          expect(datafields_catalog.control_fields.count).to eq 3
        end

        it 'get mms_id' do
          expect(datafields_catalog.mms_id).to eq mms_id
        end

        context '# From regular fields' do

          # One-occurence mapping: there are two 264 datafields in record, only the first one is added
          it 'get regular datafield tags' do
            expect(datafields_catalog.data_fields_group[:normal].map(&:tag)).to eq alma_tags
          end

          it 'get datafield tags with pre_existed datafield defined in csv' do
            expect(datafields_catalog.data_fields_group[:pre_tag].map(&:tag)).to eq alma_tags_with_pre_existed_tag
          end

          it 'get datafield tags with pre_existed datafield and subfield defined in csv' do
            expect(datafields_catalog.data_fields_group[:pre_tag_subfield].map(&:tag)).to eq alma_tags_with_pre_existed_tag_subfield
          end

        end

        context '# From 880 fields' do
          it 'get 880 datafields -  subfield 6 number is 00 ' do
            expect(datafields_catalog.fields_880_subfield6(datafields_catalog.data_fields_880_00)).to eq f880_sbufield6_with_00
          end

          it 'get 880 datafields -  subfield 6 number is not 00 ' do
            expect(datafields_catalog.fields_880_subfield6(datafields_catalog.data_fields_880_00)).not_to include not_f880_sbufield6_with_00
          end

          it 'get regular subfield 6' do
            expect(datafields_catalog.fields_880_subfield6(datafields_catalog.data_fields_880_group[:normal])).to eq f880_subfield6
          end

          it 'get regular subfield 6: pre_exsisted datafield' do
            expect(datafields_catalog.data_fields_880_group[:pre_tag]).to eq f880_subfield6_with_pre_existed_tag
          end

          it 'get regular subfield 6: pre_exsisted datafield and subfield from' do
            expect(datafields_catalog.fields_880_subfield6(datafields_catalog.data_fields_880_group[:pre_tag_subfield])).to eq f880_subfield6_with_pre_existed_tag_subfield
          end
        end

      end
    end
  end
end
