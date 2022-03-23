require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'TindControlSubfield' do
        let(:dummy_obj) { Class.new { extend TindControlSubfield } }
        let(:dumy_obj_multiple_mapper) { Class.new { extend CsvMultipleMapper } }
        let(:leader_rules) { dumy_obj_multiple_mapper.rules[:tag_008] }
        let(:rule) { leader_rules[1] }
        # When 001 value is copied from xml file, it missed 13 spaces, added manually
        let(:leader_val_normal)   { '970502i19101920vp nnn              kneng d' }
        let(:leader_val_uu)       { '970423q19uu19uuxxunnn              kneng d' }
        let(:leader_val_u)        { '970501q195u195ule nnn              kneng d' }
        let(:leader_val_not_good) { '970501i caunnn                     kneng d' }

        context '#Normal year - 269 field' do
          let(:sub_val) { dummy_obj.extract_value(rule, leader_val_normal) }

          it '#extract_value year in dddd' do
            expect(sub_val).to eq '1910'
          end

          it '#extracted_field - 269__$a: dddd' do
            field = dummy_obj.extracted_field(rule, sub_val)
            expect(field.tag).to eq '269'
            expect(field['a']).to eq '1910'
          end

          it '#extracted_fields_from_leader: get two fields' do
            fields = dummy_obj.extracted_fields_from_leader(leader_rules, leader_val_normal)
            expect(fields.map(&:tag)).to eq ['041', '269']
          end
        end

        context '#Year with "uu" - 269 field' do
          let(:sub_val) { dummy_obj.extract_value(rule, leader_val_uu) }

          it '#extract_value year in dduu' do
            expect(sub_val).to eq '19uu'
          end

          it '#extracted_field - 269 = nil' do
            field = dummy_obj.extracted_field(rule, sub_val)
            expect(field).to eq nil
          end

          it '#extracted_fields_from_leader: get one field ' do
            fields = dummy_obj.extracted_fields_from_leader(leader_rules, leader_val_uu)
            expect(fields.map(&:tag)).to eq ['041']
          end

        end

        context '#Year with "u" - 269 field' do
          let(:sub_val) { dummy_obj.extract_value(rule, leader_val_u) }

          it '#extract_value year in dddu' do
            expect(sub_val).to eq '195u'
          end

          it '#extracted_field - 269__$a: ddd0' do
            field = dummy_obj.extracted_field(rule, sub_val)
            expect(field.tag).to eq '269'
            expect(field['a']).to eq '1950'
          end

          it '#extracted_fields_from_leader: get two fields ' do
            fields = dummy_obj.extracted_fields_from_leader(leader_rules, leader_val_u)
            expect(fields.map(&:tag)).to eq ['041', '269']
          end

        end

        context '#None year - 269 field' do
          let(:sub_val) { dummy_obj.extract_value(rule, leader_val_not_good) }

          it '#extract_value year - not integer string' do
            expect(sub_val).to eq ' cau'
          end

          it '#extracted_field - 269 = nil' do
            field = dummy_obj.extracted_field(rule, sub_val)
            expect(field).to eq nil
          end

          it '#extracted_fields_from_leader: get one field ' do
            fields = dummy_obj.extracted_fields_from_leader(leader_rules, leader_val_uu)
            expect(fields.map(&:tag)).to eq ['041']
          end

        end
      end
    end
  end
end
