require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindMarc' do
        let(:tind_marc) { TindMarc.new(Config.test_record) }
        let(:fake_tindfields) do
          [TindField.f_fft('https://digitalassets.lib.berkeley.edu/pre1912ChineseMaterials/ucb/ready/991032333019706532/991032333019706532_v001_0064.jpg',
                           'v001_0064')]
        end

        # mapped on pre_existed_field rule: "260"
        # mapped on pre_existed_subfield rule:  "255"
        let(:tindfield_tags) do
          %w[255 245 246 260 300 300 490 630 650
             650 700 710 903 041 269 255]
        end

        # mapped on pre_existed_field rule  => ''
        # mapped on pre_existed_subfield rule:  "880-255-09"
        # 880 datafields with '00' in subfield 6 come from field_catalog - 4 tindfields
        let(:tindfield_880_normal_tags) do
          %w[880-245-01 880-246-02 880-260-03 880-490-04
             880-650-05 880-700-06 880-710-07 880-255-09
             880-500-00 880-500-00 880-500-00 880-500-00]
        end

        it 'get a TIND record' do
          expect(tind_marc.tind_record).to be_a ::MARC::Record
        end

        it 'get all tindfields' do
          expect(tind_marc.tindfields.count).to eq 29  # 8 (normal tindfields) + 21 (880 tindfields)
        end

        it 'get normal tindfield tags' do
          expect(tind_marc.send(:tindfields_group).map(&:tag)).to eq tindfield_tags
        end

        it 'get 880 tindfield subfield6 values' do
          expect(tind_marc.fields_880_subfield6(tind_marc.send(:tindfields_group_880))).to eq tindfield_880_normal_tags
        end

        xit 'save tind marc to file' do
          tind_marc.tind_external_datafields = fake_tindfields
          file = 'tmp/tind_marc_test.xml'
          File.delete(file) if File.exist?(file)
          tind_marc.save(file)
          expect(File.exist?(file)).to be true

        end

      end
    end
  end
end
