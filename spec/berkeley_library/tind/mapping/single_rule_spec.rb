require 'spec_helper'
require 'csv'

module BerkeleyLibrary
  module TIND
    module Mapping

      describe 'SingleRule' do

        attr_reader :single_rule

        before(:each) do
          # row = instance_double(CSV::Row)
          # row = double
          # allow(row).to receive(:tag_origin).and_return("245")
          # allow(row).to receive(:tag_destination).and_return("245")
          # allow(row).to receive(:Map_if_no_this_tag_existed).and_return('246')
          # allow(row).to receive(:Map_if_no_this_tag_subfield_existed).and_return("700_a")
          # allow(row).to receive(:Keep_one_if_multiple_available).and_return('701')
          # allow(row).to receive(:subfield_single_from).and_return("b")
          # allow(row).to receive(:subfield_single_to).and_return("b")
          # allow(row).to receive(:subfield_combined_from_1).and_return('a,c,d')
          # allow(row).to receive(:subfield_combined_to_1).and_return("a")
          # allow(row).to receive(:symbol_1).and_return(['--'])
          # allow(row).to receive(:subfield_combined_from_2).and_return('k,f,b')
          # allow(row).to receive(:subfield_combined_to_2).and_return("b")
          # allow(row).to receive(:symbol_2).and_return([' '])
          # allow(row).to receive(:subfield_combined_from_3).and_return('x,y,z')
          # allow(row).to receive(:subfield_combined_to_3).and_return("a")
          # allow(row).to receive(:symbol_3).and_return(['--'])
          rows = Util.csv_rows('spec/data/mapping/one_to_one_mapping.csv')
          @single_rule = SingleRule.new(rows[3])
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
