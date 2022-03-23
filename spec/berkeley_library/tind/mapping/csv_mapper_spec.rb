require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'CsvMapper' do
        let(:dummy_class) { Class.new { extend CsvMapper } }
        let(:from_tag) { %w[100 110 111 242 245 246 250 255 260 264 300 351 490 500 502 505 507 520 522 524 536 540 541 545 546 600 610 611 630 650 651 655 700 710 711 720 752 773 907] }
        let(:rules_keys) { %i[tag_100 tag_110 tag_111 tag_242 tag_245 tag_246 tag_250 tag_255 tag_260 tag_264 tag_300 tag_351 tag_490 tag_500 tag_502 tag_505 tag_507 tag_520 tag_522 tag_524 tag_536 tag_540 tag_541 tag_545 tag_546 tag_600 tag_610 tag_611 tag_630 tag_650 tag_651 tag_655 tag_700 tag_710 tag_711 tag_720 tag_752 tag_773 tag_907] }

        it 'get origin tags' do
          expect(dummy_class.from_tags).to eq from_tag
        end

        it 'get keys of rules' do
          expect(dummy_class.rules.keys).to eq rules_keys
        end

        it 'get tag required one occurrence in csv ' do
          expect(dummy_class.one_occurrence_tags).to eq ['264']
        end

      end
    end
  end
end
