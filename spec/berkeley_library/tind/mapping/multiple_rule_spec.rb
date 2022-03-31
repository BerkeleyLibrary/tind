require 'spec_helper'
require 'csv'

module BerkeleyLibrary
  module TIND
    module Mapping

      describe MultipleRule do

        attr_reader :multiple_rule

        before(:each) do
          rows = Util.csv_rows('spec/data/mapping/one_to_multiple_mapping.csv')
          @multiple_rule = MultipleRule.new(rows[0])
        end

        it 'get origin tag' do
          expect(multiple_rule.tag_origin).to eq '008'
        end

        it 'get destination tag' do
          expect(multiple_rule.tag_destination).to eq '041'
        end

        it 'get indicator' do
          expect(multiple_rule.indicator).to eq [' ', ' ']
        end

        it 'get pre_existed tag' do
          expect(multiple_rule.pre_existed_tag).to eq '041'
        end

        it 'get subfield key' do
          expect(multiple_rule.subfield_key).to eq 'a'
        end

        it 'get position from and to' do
          expect(multiple_rule.position_from_to).to eq [35, 37]
        end

      end
    end
  end
end
