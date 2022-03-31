require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe CsvMultipleMapper do
        let(:dummy_class) { Class.new { extend CsvMultipleMapper } }
        let(:from_tag) { ['008', 'LDR'] }
        let(:rules_keys) { %i[tag_008 tag_LDR] }

        it 'get origin tags' do
          expect(dummy_class.from_tags).to eq from_tag
        end

        it 'get keys of rules' do
          expect(dummy_class.rules.keys).to eq rules_keys
        end

        it 'get 2 rules on tag "008" ' do
          expect(dummy_class.send(:rules_on_tag, '008').count).to eq 2
        end

      end
    end
  end
end
