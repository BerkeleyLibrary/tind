require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      # using 008 field: csv file, one_to_multiple csv file should have 008 field
      # tag_origin	tag_destination	map_if_no_this_tag_existed	subfield_key	new_indecator	value_from	value_to
      # 008	      41             	41	                         a            _,_	          35	         37
      # 008	      269	                                         a	          _,_         	7	           10

      describe 'TindFieldFromMultipleMap' do

        attr_reader :tindfield_from_multiple_map

        before(:each) do
          @tindfield_from_multiple_map = TindFieldFromMultipleMap.new(Config.test_control_field, [])
        end

        it 'get tindfields without pre_existing tindfields' do
          expect(@tindfield_from_multiple_map.to_datafields.count).to eq 2
        end

        it 'get tindfields with pre_existing tindfields' do
          current_fields = [] << ::MARC::DataField.new('041', ' ', ' ', ::MARC::Subfield.new('a', 'chi'))
          multiple_map = TindFieldFromMultipleMap.new(Config.test_control_field, current_fields)
          expect(multiple_map.to_datafields.count).to eq 1
        end

      end
    end
  end
end
