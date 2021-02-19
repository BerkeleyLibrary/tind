require 'ucblit/tind/api/search'
require 'rodf'

module UCBLIT
  module TIND
    module Exporter
      class << self

        def export_csv(collection, out = $stdout)
          table = table_for(collection)
          table.to_csv(out)
        end

        def export_libreoffice(collection, out = $stdout)
          table = table_for(collection)
          ss = RODF::Spreadsheet.new do
            table(collection) do
              row { table.headers.each { |h| cell(h) } }
              table.each_row { |r| row { r.each_value { |v| cell(v) } } }
            end
          end
          out.write(ss.bytes)
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
