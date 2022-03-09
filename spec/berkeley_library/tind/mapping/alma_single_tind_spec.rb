require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'AlmaSingleTIND' do
        let(:tind_marc) { TindMarc.new(Config.test_record) }
        let(:alma_single_tind) { AlmaSingleTIND.new }

        BerkeleyLibrary::TIND::Mapping::AlmaBase.collection_parameter_hash = {
          '336' => ['Image'],
          '852' => ['East Asian Library'],
          '980' => ['pre_1912'],
          '982' => ['Pre 1912 Chinese Materials - short name', 'Pre 1912 Chinese Materials - long name'],
          '991' => []
        }

        it 'get a TIND record' do
          expect(alma_single_tind.send(:tind_record, '991085821143406532', Config.test_record, [])).to be_a ::MARC::Record
        end

        it 'get derived fields' do
          expect(alma_single_tind.send(:derived_tind_fields, '991085821143406532', '991085821143406532').count).to eq 7  # 4+6
        end

      end
    end
  end
end
