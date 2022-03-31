require 'spec_helper'
require 'csv'

module BerkeleyLibrary
  module TIND
    module Mapping

      describe SingleRule do

        attr_reader :single_rule

        before(:each) do
          rows = Util.csv_rows('spec/data/mapping/one_to_one_mapping.csv')
          @single_rule = SingleRule.new(rows[4])
        end

        it 'get origin tag' do
          expect(single_rule.tag_origin).to eq '245'
        end

        it 'get destination tag' do
          expect(single_rule.tag_destination).to eq '245'
        end

        it 'get indicator' do
          expect(single_rule.indicator).to eq [' ', ' ']
        end

        it 'get combined rules' do
          expect(single_rule.combined_rules).to eq [[['n,p', 'p', nil]], [['b,f,k', 'b', nil]]] # combination rules mapped to p and b
        end

        it 'get pre_existed_tag' do
          expect(single_rule.pre_existed_tag).to eq nil
        end

        it 'get pre_existed_tag_subfield ' do
          expect(single_rule.pre_existed_tag_subfield).to eq nil
        end

        it 'get single rule exluding pre_existed_subfield hash' do
          expect(single_rule.single_rule_subfield_excluded_hash).to eq({ '6' => '6', 'a' => 'a' })
        end

        it 'get single rule' do
          expect(single_rule.single_rule_hash).to eq({ '6' => '6', 'a' => 'a' })
        end

      end
    end
  end
end
