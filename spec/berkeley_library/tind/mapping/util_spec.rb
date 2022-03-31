require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe Util do

        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }

        let(:un_qualified_alma_obj) { Alma.new('spec/data/mapping/record_not_qualified.xml') }
        let(:un_qualified_alm_record) { un_qualified_alma_obj.record }

        let(:field) { qualified_alma_obj.field('260') }
        let(:subfield_hash) do
          { '6' => '880-03',
            'a' => '[Daliang] :',
            'b' => 'Daliang fu shu,',
            'c' => 'Qing Qianlong 50 nian [1785]' }
        end

        it 'get three digits' do
          tag = '1'
          expect(Util.send(:format_tag, tag)).to eq '001'
        end

        it 'get letters' do
          tag = 'LDR'
          expect(Util.send(:format_tag, tag)).to eq 'LDR'
        end

        it 'get subfield hash from a field' do
          expect(Util.subfield_hash(field)).to eq subfield_hash
        end

        it 'get qualified alma record' do
          expect(Util.qualified_alma_record?(qualified_alm_record)).to eq true
        end

        it 'get unqualified alma record' do
          expect(Util.qualified_alma_record?(un_qualified_alm_record)).to eq false
        end

        it 'get symbol from string "a--a"' do
          expect(Util.concatenation_symbol('a--a')).to eq ' -- '
        end

        it 'get symbol from nil' do
          expect(Util.concatenation_symbol(nil)).to eq ' '
        end

      end
    end
  end
end
