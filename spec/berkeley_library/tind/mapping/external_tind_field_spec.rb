require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe ExternalTindField do
        describe '# tind_fields_from_collection_information' do
          let(:good_hash) do
            {   '336' => ['Image'],
                '852' => ['East Asian Library'],
                '980' => ['pre_1912'],
                '982' => ['Pre 1912 Chinese Materials', 'Pre 1912 Chinese Materials'],
                '991' => [] }
          end
          let(:bad_hash) { {} }
          let(:output_collection_tags) { %w[336 852 980 982] }

          it 'get tind datafields derived from collection information' do
            expect(ExternalTindField.tind_fields_from_collection_information(good_hash).map(&:tag)).to eq output_collection_tags
          end

          it 'get [] derived from empty collection information' do
            expect(ExternalTindField.tind_fields_from_collection_information(bad_hash).map(&:tag)).to eq []
          end
        end

        describe '# tind_fields_from_alma_id' do
          let(:output_alma_tags) { %w[901 856] }

          it 'get derived tind fields from alma id' do
            alma_id = '991085821143406532'
            expect(ExternalTindField.tind_mms_id_fields(alma_id).map(&:tag)).to eq output_alma_tags
          end

          it 'get empty tind fields from a nil alma id' do
            alma_id = nil
            expect(ExternalTindField.tind_mms_id_fields(alma_id).map(&:tag)).to eq []

          end
        end

      end
    end
  end
end
