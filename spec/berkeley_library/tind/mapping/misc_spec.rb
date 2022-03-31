require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe Misc do
        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }

        let(:tind_marc) { TindMarc.new(qualified_alm_record) }
        let(:regular_field_with_subfield6) { qualified_alma_obj.field('246') }
        let(:field_880_with_subfield6) { qualified_alma_obj.field_880('490-04/$1') }
        let(:field_880_without_subfield6) { qualified_alma_obj.field_880(nil) }

        it 'get field tag' do
          expect(tind_marc.origin_mapping_tag(regular_field_with_subfield6)).to eq '246'
        end

        it 'get tag from subfield 6' do
          expect(tind_marc.origin_mapping_tag(field_880_with_subfield6)).to eq '490'
        end

        it 'get nil when no fubfiel6' do
          expect(tind_marc.referred_tag(field_880_without_subfield6)).to eq nil
        end

        it '880 field has a refered tag' do
          expect(tind_marc.field_880_has_referred_tag?('490', field_880_with_subfield6)).to eq true
        end

        it '880 field has no refered tag' do
          expect(tind_marc.field_880_has_referred_tag?('490', field_880_without_subfield6)).to eq false
        end

        it 'remove defined punctuations' do
          expect(tind_marc.send(:clr_value, ' [1785] Qing Qianlong 50 nian :,')).to eq '1785  Qing Qianlong 50 nian'
        end

        it 'get seq number' do
          expect(tind_marc.send(:seq_no, '245-01/$1')).to eq 1
        end

        it 'get seq number - 0' do
          expect(tind_marc.send(:seq_no, '550')).to eq 0
        end

      end
    end
  end
end
