require 'rodf'
require 'ucblit/tind/api/search'
require 'ucblit/tind/export/table'
require 'ucblit/tind/export/export_format'

module UCBLIT
  module TIND
    module Export

      class << self
        include UCBLIT::TIND::Config

        def export(collection, format = ExportFormat::CSV, out = $stdout)
          ExportFormat.ensure_format(format).export(collection, out)
        end

        def export_csv(collection, out = $stdout)
          table = table_for(collection)
          logger.info('Writing CSV')
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
          logger.info("Reading collection #{collection.inspect}")
          search = API::Search.new(collection: collection)
          results = search.each_result(freeze: true)

          logger.info('Creating export table')
          # noinspection RubyYardParamTypeMatch
          Export::Table.from_records(results, freeze: true)
        end

        def libreoffice_spreadsheet_for(collection)
          table = table_for(collection)
          logger.info('Creating spreadsheet')
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
