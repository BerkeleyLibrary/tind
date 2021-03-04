require 'csv'
require 'ucblit/tind/export/exporter_base'

module UCBLIT
  module TIND
    module Export
      # Exporter for CSV (comma-separated value) text
      class CSVExporter < ExporterBase
        # Exports {ExportBase#collection} as CSV
        # @overload export
        #   Exports to a new string.
        #   @return [String] the CSV string
        # @overload export(out)
        #   Exports to the specified output stream.
        #   @param out [IO] the output stream
        #   @return[void]
        # @overload export(path)
        #   Exports to the specified file.
        #   @param path [String, Pathname] the path to the output file
        #   @return[void]
        def export(out = nil)
          # noinspection RubyYardReturnMatch
          export_table.tap { logger.info('Writing CSV') }.to_csv(out)
        end

      end
    end
  end
end
