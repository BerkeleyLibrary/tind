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

        after do
          BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags = []
          BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags = []
        end

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

        context 'Defining list of fields mapping from Alma to TIND' do
          it 'no including, excluding defined from config, return all Alma fields for mapping' do
            selected_field_tags = %w[255 507 245 246 260 300]
            fields = qualified_alm_record.fields.select { |f| selected_field_tags.include? f.tag }
            expect(fields_to_map(fields).map(&:tag)).to eq %w[255 507 245 246 260 300 300]
          end

          it 'both including and excluding have tags, return empty: not allow to define both including and excluding at the same time' do
            BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags = %w[254 650]
            BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags = %w[507 255 650 880]

            selected_field_tags = %w[255 507 245 246 260 300]
            fields = qualified_alm_record.fields.select { |f| selected_field_tags.include? f.tag }
            expect(fields_to_map(fields).map(&:tag)).to eq []
          end

          it 'only including is defined: keeping fields defined in BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags' do
            selected_field_tags = regular_field_tags
            selected_field_tags << '880'
            selected_field_tags << '001'
            fields = qualified_alm_record.fields.select { |f| selected_field_tags.include? f.tag }
            BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags = %w[255 650]
            expect(fields_to_map(fields).map(&:tag)).to eq %w[001 255 650 650 880] # return: Two 650 fields, one 880 field with subfield6 = '650'
          end

          context 'only excluding origin tags are defined ' do
            it 'excluding has 880, all 880 fields will be excluded.' do
              selected_field_tags = %w[001 880 245 507 255 650 630 700 264]
              fields = qualified_alm_record.fields.select { |f| selected_field_tags.include? f.tag }
              BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags = %w[507 255 650 880]
              final_field_tags = %w[001 245 630 700 264 264] # no 880 fields kept
              expect(fields_to_map(fields).map(&:tag)).to eq final_field_tags
            end

            it 'excluding has no 880, only 880 whose refered tag located in excluding list will be skipped ' do
              selected_field_tags = %w[001 880 245 507 255 650 630 700 264]
              fields = qualified_alm_record.fields.select { |f| selected_field_tags.include? f.tag }
              BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags = %w[507 255 650]
              final_field_tags = %w[001 245 880 880 880 880 630 880 700 880 880 880 880 880 880 880 264 264]
              expect(fields_to_map(fields).map(&:tag)).to eq final_field_tags
            end
          end
        end
      end
    end
  end
end
