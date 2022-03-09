require 'csv'

module BerkeleyLibrary
  module TIND
    module Mapping
      module CsvMultipleMapper
        @rows = []
        class << self
          attr_accessor :rows
        end

        CsvMultipleMapper.rows = Util.csv_rows(Config.one_to_multiple_map_file)
        def from_tags
          tags = []
          CsvMultipleMapper.rows.each do |row|
            tag = row[:tag_origin]
            tags << tag unless tags.include?(tag)
          end
          tags
        end

        def rules
          from_tags.to_h { |tag| [Util.tag_symbol(tag), rules_on_tag(tag)] }
        end

        private

        def rules_on_tag(tag)
          rules = []
          CsvMultipleMapper.rows.each do |row|
            origin_tag = row[:tag_origin]
            rules << MultipleRule.new(row) if origin_tag == tag
          end
          # puts "!!! #{rules.inspect}"
          rules
        end

      end
    end
  end
end
