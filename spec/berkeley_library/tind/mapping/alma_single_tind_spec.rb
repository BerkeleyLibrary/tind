require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'AlmaSingleTIND' do
        let(:additona_245_field) { [Util.datafield('245', [' ', ' '], [Util.subfield('a', 'fake 245 a')])] }

        it ' # record' do
          # AlmaBase.base_tind_record(id, datafields, alma_record = nil)

          alma_single_tind = instance_double(BerkeleyLibrary::TIND::Mapping::AlmaSingleTIND)

          allow(alma_single_tind).to receive(:record).with('991085821143406532', additona_245_field).and_return(::MARC::Record.new)
          expect(alma_single_tind.record('991085821143406532', additona_245_field)).to be_instance_of ::MARC::Record
        end
      end
    end
  end
end
