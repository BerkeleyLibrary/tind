require 'csv'
require 'berkeley_library/tind/mapping/util'

module BerkeleyLibrary
  module TIND
    module Mapping
      module CsvMapper
        @rows = []
        class << self
          attr_accessor :rows
        end

        CsvMapper.rows = Util.csv_rows(Config.one_to_one_map_file)

        def from_tags
          CsvMapper.rows.map { |row| row[:tag_origin] }.compact
        end

        def rules
          CsvMapper.rows.to_h { |row| ["tag_#{row[:tag_origin]}".to_sym, SingleRule.new(row)] }
        end

        # tags allow to keep the first datafield from original marc record
        def one_occurrence_tags
          tags = []
          CsvMapper.rows.each do |row|
            tags << row[:tag_origin] if row[:keep_one_if_multiple_available]
          end
          tags.compact
        end

      end
    end
  end
end
