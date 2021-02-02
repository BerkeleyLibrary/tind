require 'ucblit/tind/marc_table'

require 'csv'

module UCBLIT
  module TIND
    class Exporter
      attr_reader :records

      def initialize(records)
        @records = records
      end

      def table
        @table ||= MARCTable.new.tap do |table|
          records.each { |r| table << r }
        end
      end

      def to_csv
        # TODO: use roo instead of ::CSV
        # TODO: support writing to IO or file
        CSV.generate do |csv|
          csv << table.headers
          table.each_row { |row| csv << row.values }
        end
      end
    end
  end
end
