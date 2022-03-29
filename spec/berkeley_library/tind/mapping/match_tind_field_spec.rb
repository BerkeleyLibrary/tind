require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'MatchTindField' do
        let(:tind_marc) { TindMarc.new(Config.test_record) }

        let(:data_fields) { tind_marc.field_catalog.data_fields_880_group[:normal].concat tind_marc.field_catalog.data_fields_group[:normal] }
        let(:no_880_matching_count) { 4 }

        it 'get 880 un-matched fields' do
          puts tind_marc.send(:un_matched_fields_880, data_fields, '991032577079706532').inspect
          expect(tind_marc.send(:un_matched_fields_880, data_fields, '991032577079706532').length).to eq no_880_matching_count
        end

      end
    end
  end
end
