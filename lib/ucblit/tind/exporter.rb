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
          ss = libreoffice_spreadsheet_for(collection)
          return write_spreadsheet_to_stream(out, ss) if out.respond_to?(:write)

          write_spreadsheet_to_file(out, ss)
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

        def libreoffice_spreadsheet_for(collection)
          table = table_for(collection)
          RODF::Spreadsheet.new do
            table(collection) do
              row { table.headers.each { |h| cell(h) } }
              table.each_row { |r| row { r.each_value { |v| cell(v) } } }
            end
          end
        end

        def write_spreadsheet_to_stream(out, spreadsheet)
          out.write(spreadsheet.bytes)
        end

        def write_spreadsheet_to_file(path, spreadsheet)
          File.open(path, 'wb') { |f| write_spreadsheet_to_stream(f, spreadsheet) }
        end
      end
    end
  end
end
