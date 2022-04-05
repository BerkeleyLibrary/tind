require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe FieldCatalogUtil do
        include Util
        include Misc
        include FieldCatalogUtil
        include TindSubfieldUtil
        include CsvMapper
        
        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }
        let(:regular_field_tags) do
          %w[255
             507
             245
             246
             260
             300
             490
             630
             650
             700
             710
             264]
        end

        let(:normal) { %w[255 245 246 260 300 300 490 630 650 650 700 710] }
        let(:pre_tag) { ['264', '264'] }
        let(:pre_tag_subfield) { ['507'] }

        it 'excluding fast subject field' do
          fields = qualified_alm_record.fields.select { |f| ['650', '245'].include? f.tag }
          expect(fields.length).to eq 3

          final_fields = exluding_fields_with_fast_subject(fields)
          expect(final_fields.length).to eq 2
          expect(final_fields[0].tag).to eq '245'

        end

        it 'preparing field group' do
          fields = qualified_alm_record.fields.select { |f| regular_field_tags.include? f.tag }
          expect(fields.length).to eq 15

          group = prepare_group(fields)
          expect(group[:normal].map(&:tag)).to eq normal
          expect(group[:pre_tag].map(&:tag)).to eq pre_tag
          expect(group[:pre_tag_subfield].map(&:tag)).to eq pre_tag_subfield
        end

      end
    end
  end
end
