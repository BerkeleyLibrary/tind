require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'AdditionalDatafieldProcess' do
        let(:tind_marc) { TindMarc.new(Config.test_record) }
        let(:tindfields) { tind_marc.tindfields }
        let(:additona_245_field) { [Util.datafield('245', [' ', ' '], [Util.subfield('a', 'fake 245 a')])] }
        let(:with_repeated_fields) { tindfields.concat additona_245_field }

        context '# Process 1: Remove duplicated fields' do
          # two 245 fields inputed, one is removed
          it 'Input two 245 fields, return only one 245 field' do
            expect(tind_marc.remove_repeats(with_repeated_fields).map(&:tag).count('245')).to eq 1
          end

          # one subfield 'a' is kept, subfield 'a' with a value of 'fake 245 a' is ignored
          it 'Input two subfield $a, keeping the first one' do
            without_repeated_fields = tind_marc.remove_repeats(with_repeated_fields)
            single_field_245 = tind_marc.field_on_tag('245', without_repeated_fields)
            expect(single_field_245['a']).to eq 'Cang jie pian'
          end
        end

      end

    end
  end
end
