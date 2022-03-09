require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindFieldFromLeader' do
        attr_reader :tindfield_from_leader

        before(:each) do
          @tindfield_from_leader = TindFieldFromLeader.new(Config.test_record)
        end

        it 'get_tindfields' do
          expect(@tindfield_from_leader.to_datafields[0].tag).to eq '903'
        end

      end
    end
  end
end
