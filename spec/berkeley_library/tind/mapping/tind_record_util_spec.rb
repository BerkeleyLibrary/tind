require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe TindRecordUtil do
        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }
        let(:tind_marc) { TindMarc.new(qualified_alm_record).tind_record }

        it 'Remove fields from record' do
          fields_removal_list = [%w[245 _ _], %w[700 1 _], %w[880 _ _]] # '_' means empty indicator
          results = %w[255 246 260 300 300 490 630 650 710 903 041 269 255 880 880 880] # some 880's inicator is not empty
          new_record = TindRecordUtil.update_record(tind_marc, nil, fields_removal_list)
          expect(new_record.fields.map(&:tag)).to eq results
        end

        it 'add/update sufields from record' do
          tag_subfield_dic = { '245' => { 'b' => 'subtitle', 'a' => 'title', 'd' => 'fake' }, '255' => { 'a' => nil } }
          new_record = TindRecordUtil.update_record(tind_marc, tag_subfield_dic, nil)
          expect(new_record['245']['a']).to eq 'title'
          expect(new_record['245']['b']).to eq 'subtitle'
          expect(new_record['245']['d']).to eq 'fake'
          expect(new_record['255']['a']).to eq 'fake_255_a'
        end
      end
    end
  end
end
