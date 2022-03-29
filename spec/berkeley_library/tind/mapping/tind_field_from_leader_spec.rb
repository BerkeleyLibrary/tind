require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindFieldFromLeader' do

        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }
        let(:datafields_catalog) { DataFieldsCatalog.new(qualified_alm_record) }
        let(:tindfield_from_leader) { TindFieldFromLeader.new(qualified_alm_record) }

        it 'get_tindfields' do
          expect(tindfield_from_leader.to_datafields[0].tag).to eq '903'
        end

      end
    end
  end
end
