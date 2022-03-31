require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe Config do

        it 'get the one to one mapping file' do
          expect(Config.one_to_one_map_file).to end_with('one_to_one_mapping.csv')
        end

        it 'get the one to multiple mapping file' do
          expect(Config.one_to_multiple_map_file).to end_with('one_to_multiple_mapping.csv')
        end

      end
    end
  end
end
