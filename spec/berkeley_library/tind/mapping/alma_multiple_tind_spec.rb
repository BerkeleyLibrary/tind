require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'AlmaMultipleTIND' do
        let(:additona_245_field) { [Util.datafield('245', [' ', ' '], [Util.subfield('a', 'fake 245 a')])] }
        let(:marc_obj) { (::MARC::Record.new).append(additona_245_field) }

        it ' get tind record' do
          allow_any_instance_of(BerkeleyLibrary::TIND::Mapping::AlmaMultipleTIND).to receive(:alma_record_from).with('991085821143406532').and_return(marc_obj)
          alma_multiple_tind = BerkeleyLibrary::TIND::Mapping::AlmaMultipleTIND.new('991085821143406532')

          allow(alma_multiple_tind).to receive(:base_tind_record).with('991085821143406532', additona_245_field, marc_obj).and_return(marc_obj)
          expect(alma_multiple_tind.record(additona_245_field)).to be marc_obj
        end
      end
    end
  end
end
