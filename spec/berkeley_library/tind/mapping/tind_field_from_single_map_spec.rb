require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe TindFieldFromSingleMap do
        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }
        let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('245'), false) }

        # 1. Subfield one to one mapping
        # 2. Subfield not listed in csv file is not mapped
        describe '1. subfield one to one mapping' do
          it 'get tindfield tag: 245 => 245 ' do
            expect(tindfield_from_single_map.to_datafield.tag).to eq '245'
          end

          it 'get 245$a' do
            expect(tindfield_from_single_map.to_datafield['a']).to eq 'Cang jie pian :'
          end

          it 'get 245$b' do
            expect(tindfield_from_single_map.to_datafield['b']).to eq '[san juan] /'
          end

          it 'get 245$6' do
            expect(tindfield_from_single_map.to_datafield['6']).to eq '880-99'
          end

          it 'shoud not get 245$c' do
            expect(tindfield_from_single_map.to_datafield['c']).to eq nil
          end
        end
        describe '2. mapping indicators' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('710'), false) }

          it 'get indicator1' do
            expect(tindfield_from_single_map.to_datafield.indicator1).to eq '2'
          end

          it 'get indicator2' do
            expect(tindfield_from_single_map.to_datafield.indicator2).to eq ' '
          end

        end

        # 264 datafield mapping defined in csv has only one mapping occurrence
        # To test only the first occurrence is mapped
        describe '3. multiple origin 264 fields => only mapping the first occurrence' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('264'), false) }

          it 'get tindfield tag: 264 => 260' do
            expect(tindfield_from_single_map.to_datafield.tag).to eq '260'
          end

          it 'get the first 264$a' do
            expect(tindfield_from_single_map.to_datafield['a']).to eq '264 fake a 1'
          end

          it 'get the first 264$b' do
            expect(tindfield_from_single_map.to_datafield['b']).to eq '264 fake b 1'
          end

          it 'get the first 264$c' do
            expect(tindfield_from_single_map.to_datafield['c']).to eq '264 fake c 1'
          end
        end

        # 1. 507 datafield has pre-existed subfield a defined in csv file
        # 2. To test excluding subfield a mapping from  507
        # 3. TindFieldFromSingleMap.new(): input excluding_subfield = true
        describe '4. pre_existed subfield = true' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('507'), true) }

          it 'get tindfield tag: 507 => 255 ' do
            expect(tindfield_from_single_map.to_datafield.tag).to eq '255'
          end

          it 'pre_existed 507$a is not mapped' do
            expect(tindfield_from_single_map.to_datafield['a']).to eq nil
          end
        end

        # To test rule: subfield value combined without concatenation symbol defined in csv
        describe '5. subfields are combined' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('246'), false) }

          it 'get tindfield tag: 246 => 246' do
            expect(tindfield_from_single_map.to_datafield.tag).to eq '246'
          end

          it 'get combined subfield a, b, p, n' do
            expect(tindfield_from_single_map.to_datafield['a']).to eq 'Sun shi Cang jie pian ^^ b fake ^^ p fake ^^ n fake'
          end

        end

        # To test multiple rules mapped to the same tinddatafield
        describe '6. subfields are combined with multiple rules' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('630'), false) }
          let(:combined_value) { 'fake a *  fake b * fake c * fake d * fake f * fake j * fake k * fake l * fake m * fake n * fake o * fake p * fake q * fake r * fake s * fake t * fake x1  -- fake x2  ' }

          it 'get tindfield tag: 630 => 630' do
            expect(tindfield_from_single_map.to_datafield.tag).to eq '630'
          end

          it 'get combined subfield a, b, p, n' do
            expect(tindfield_from_single_map.to_datafield['a']).to eq combined_value
          end

        end

        # 1. To test 880 datafield
        # 2. 880 tag reversed
        # 3. subfields z,y, z combined with concatenation symbol defined in csv file
        describe '7. 880 datafield mapping' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field_880('650-05/$1'), false) }

          it 'get tindfield tag: 880 => 880' do
            expect(tindfield_from_single_map.to_datafield.tag).to eq '880'
          end

          it 'get 880$a: subfield a x,y,z combined to subfield a with symbol " -- " ' do
            expect(tindfield_from_single_map.to_datafield['a']).to eq '經部 小學類 -- 字書. '
          end

        end

        # 1. To test 880 datafield
        # 2. Tag in 880 subfield 6 is mapped based on a regular datafield mapping rule
        # 3. 880 datafield with 507 tag in subfield 6
        #   mapped from 507-09/$1 to 255-09/$1
        describe '8. 880 subfield 6 value mapped to new destination tag' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field_880('507-09/$1'), false) }

          it 'get tindfield tag: 880 => 880' do
            expect(tindfield_from_single_map.to_datafield.tag).to eq '880'
          end

          it 'get subfield 6: "507-09/$1" => "255-09/$1" ' do
            expect(tindfield_from_single_map.to_datafield['6']).to eq '255-09/$1'
          end
        end

        describe '9.1 - 710: subfields ordered on mapping file order' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('710'), false) }
          it 'get subfield code ordered' do
            codes = tindfield_from_single_map.to_datafield.subfields.map(&:code)
            expect(codes).to eq %w[6 a e]
          end
        end

        describe '9.2 subfield order - 255: subfields ordered on original subfields' do
          let(:tindfield_from_single_map) { TindFieldFromSingleMap.new(qualified_alma_obj.field('255'), false) }

          it 'get subfield code ordered' do
            codes = tindfield_from_single_map.to_datafield.subfields.map(&:code)
            expect(codes).to eq %w[a c b 6]
          end
        end

      end

    end
  end
end
