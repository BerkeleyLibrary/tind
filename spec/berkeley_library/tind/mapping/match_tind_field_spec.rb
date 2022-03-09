require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'MatchTindField' do
        let(:tind_marc) { TindMarc.new(Config.test_record) }

        let(:data_fields) { tind_marc.field_catalog.data_fields_880_group[:normal].concat tind_marc.field_catalog.data_fields_group[:normal] }
        let(:no_880_matching_list) { ['No matching: 880 $ 245-01/$1 ', 'No matching: 245 $ 880-99 ', 'No matching: 630 $ 880-16 '] }

        it 'get 880 un-matched fields' do
          expect(tind_marc.send(:un_matched_fields_880, data_fields)).to eq no_880_matching_list
        end

      end
    end
  end
end
