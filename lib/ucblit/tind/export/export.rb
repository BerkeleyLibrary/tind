require 'ucblit/tind/export/export_format'

module UCBLIT
  module TIND
    module Export
      class << self
        # Writes a spreadsheet in the specified format
        # @overload export(collection, format = ExportFormat::CSV)
        #   Returns the spreadsheet as a string.
        #   @param collection [String] The collection name
        #   @param format [ExportFormat, String, Symbol] the export format
        #   @param exportable_only [Boolean] whether to include only exportable fields
        # @overload export(collection, format = ExportFormat::CSV, out)
        #   Writes the spreadsheet to the specified output stream.
        #   @param collection [String] The collection name
        #   @param format [ExportFormat, String, Symbol] the export format
        #   @param out [IO] the output stream
        #   @param exportable_only [Boolean] whether to include only exportable fields
        # @overload export(collection, format = ExportFormat::CSV, path)
        #   Writes the spreadsheet to the specified output file.
        #   @param collection [String] The collection name
        #   @param format [ExportFormat, String, Symbol] the export format
        #   @param path [String, Pathname] the path to the output file
        #   @param exportable_only [Boolean] whether to include only exportable fields
        def export(collection, format = ExportFormat::CSV, out = nil, exportable_only: true)
          # noinspection RubyYardParamTypeMatch
          export_format = ExportFormat.ensure_format(format)
          # noinspection RubyNilAnalysis
          export_format.export(collection, out, exportable_only: exportable_only)
        end

      end
    end
  end
end
