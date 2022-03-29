require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      class Config

        class << self

          def one_to_one_map_file
            ENV.fetch('ONE_TO_ONE_MAP_FILE', File.expand_path('data/one_to_one_mapping.csv', __dir__))
          end

          def one_to_multiple_map_file
            ENV.fetch('ONE_TO_ONE_MAP_FILE', File.expand_path('data/one_to_multiple_mapping.csv', __dir__))
          end

          def no_duplicated_tags
            %w[245 260 852 901 902 980].freeze
          end

          def punctuations
            %w[, : ; / =].freeze
          end

          def clean_tags
            %w[245 260 300].freeze
          end

          def collection_subfield_names
            {
              '336' => ['a'],
              '852' => ['c'],
              '980' => ['a'],
              '982' => ['a', 'b'],
              '991' => ['a']
            }.freeze
          end

        end
      end
    end
  end
end
