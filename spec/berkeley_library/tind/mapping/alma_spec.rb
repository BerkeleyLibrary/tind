require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping

      describe Alma do
        let(:alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:alma_obj_missing) { Alma.new('spec/data/mapping/record_missing_control.xml') }

        it 'control field value' do
          expect(alma_obj.control_field.tag).to eq '008'
        end

        it 'control field value' do
          expect(alma_obj_missing.control_field).to be nil
        end

        it '880 field' do
          expect(alma_obj.field_880('245-01/$1')['6']).to eq '245-01/$1'
        end

        it 'expects 880 field to be nil if no $6' do
          expect(alma_obj_missing.field_880('fake_value')).to be nil
        end

        it 'regular field' do
          expect(alma_obj.field('245').tag).to eq '245'
        end

        it 'expects non mapped field to be nil' do
          expect(alma_obj.field('99182')).to be nil
        end

      end
    end
  end
end
