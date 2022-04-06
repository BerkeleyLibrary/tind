require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe Alma do
        let(:alma_obj) { Alma.new('spec/data/mapping/record.xml') }

        it 'control field value' do
          expect(alma_obj.control_field.tag).to eq '008'
        end

        it 'control field value' do
          expect(alma_obj.control_field.tag).to eq '008'
        end

        it '880 field' do
          expect(alma_obj.field_880('245-01/$1')['6']).to eq '245-01/$1'
        end

        it 'regular field' do
          expect(alma_obj.field('245').tag).to eq '245'
        end

      end
    end
  end
end
