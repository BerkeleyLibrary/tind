module BerkeleyLibrary
  module TIND
    module Mapping

      class MultipleRule
        include Util

        attr_reader :tag_origin
        attr_reader :tag_destination
        attr_reader :indicator
        attr_reader :pre_existed_tag
        attr_reader :subfield_key
        attr_reader :position_from_to

        def initialize(row)
          @tag_origin = row[:tag_origin]
          @tag_destination = row[:tag_destination]
          @indicator = Util.indicator(row[:new_indecator])
          @pre_existed_tag = row[:map_if_no_this_tag_existed]
          @subfield_key = row[:subfield_key]
          @position_from_to = extract_position(row[:value_from], row[:value_to])
        end

        private

        # return an array with string positons for extracting value
        def extract_position(f, t)
          return nil unless f && t

          [f.to_i, t.to_i]
        end
      end

    end
  end
end
