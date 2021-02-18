require 'ucblit/tind/api/search'
require 'rspreadsheet'

module UCBLIT
  module TIND
    module Exporter
      class << self

        def export_csv(collection, out = $stdout)
          table = table_for(collection)
          table.to_csv(out)
        end

        def export_libreoffice(collection, out = $stdout)
          wb = Rspreadsheet.new
          ws = wb.create_worksheet
          table = table_for(collection)
          # NOTE: spreadsheet rows/columns are 1-indexed
          table.headers.each_with_index do |h, col|
            ws.cell(1, col + 1).value = h
          end
          table.each_row.with_index do |r, row|
            r.each_value.with_index do |v, col|
              puts("cell(#{row + 1}, #{col + 1}).value = #{v.inspect}")
              ws.cell(row + 1, col + 1).value = v
            end
          end
          wb.save(out)
        end

        private

        # Creates a table of all records in the specified
        # collection
        #
        # @param collection [String] the collection name
        # @return [Export::Table] the table
        def table_for(collection)
          search = API::Search.new(collection: collection)
          results = search.each_result(freeze: true)
          # noinspection RubyYardParamTypeMatch
          Export::Table.from_records(results, freeze: true)
        end
      end
    end
  end
end
