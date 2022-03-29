require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindSubfieldUtil' do

        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }

        let(:tind_marc) { TindMarc.new(qualified_alm_record) }

        let(:data_fields) { tind_marc.field_catalog.data_fields_880_group[:normal].concat tind_marc.field_catalog.data_fields_group[:normal] }
        let(:regular_field_with_subfield6) { qualified_alma_obj.field('246') }
        let(:regular_field_without_subfield6) { qualified_alma_obj.field('300') }
        let(:field_880_with_subfield6) { qualified_alma_obj.field_880('490-04/$1') }
        let(:field_880_without_subfield6) { qualified_alma_obj.field_880(nil) }
        let(:no_880_matching_list) { ['No matching: 880 $ 245-01/$1 ', 'No matching: 245 $ 880-99 ', 'No matching: 630 $ 880-16 '] }
        let(:subfield6_values) { ['245-01/$1', '880-16', '246-02/$04', '880-02'] }

        it 'get origin tag from regular field' do
          expect(tind_marc.origin_mapping_tag(regular_field_with_subfield6)).to eq '246'
        end

        it 'get clean value' do
          str = 'to [test] removing : special characters :;/'
          expect(tind_marc.send(:clr_value, str)).to eq 'to  test  removing : special characters'
        end

        it 'get the lowest seq no' do
          expect(tind_marc.send(:subfield6_value_with_lowest_seq_no, subfield6_values)).to eq '245-01/$1'
        end

        context 'get origin tag from a 880 field' do
          it 'with subfield6' do
            expect(tind_marc.origin_mapping_tag(field_880_with_subfield6)).to eq '490'
          end

          it 'without subfield6' do
            expect(tind_marc.origin_mapping_tag(field_880_without_subfield6)).to eq nil
          end
        end

      end
    end
  end
end
