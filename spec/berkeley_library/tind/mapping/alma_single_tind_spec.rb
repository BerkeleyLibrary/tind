require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'AlmaSingleTIND' do
        let(:additona_245_field) { [Util.datafield('245', [' ', ' '], [Util.subfield('a', 'fake 245 a')])] }
        let(:marc_obj) { (::MARC::Record.new).append(additona_245_field) }

        it ' get tind record' do
          alma_single_tind = BerkeleyLibrary::TIND::Mapping::AlmaSingleTIND.new

          allow(alma_single_tind).to receive(:base_tind_record).with('991085821143406532', additona_245_field).and_return(marc_obj)
          expect(alma_single_tind.record('991085821143406532', additona_245_field)).to be marc_obj
        end

      end
    end
  end
end
