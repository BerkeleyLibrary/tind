require 'typesafe_enum'
require 'berkeley_library/tind/export/csv_exporter'
require 'berkeley_library/tind/export/ods_exporter'

module BerkeleyLibrary
  module TIND
    module Export
      class ExportFormat < TypesafeEnum::Base
        new :CSV
        new :ODS

        DEFAULT = ODS

        def exporter_for(collection, exportable_only: true)
          return CSVExporter.new(collection, exportable_only: exportable_only) if self == ExportFormat::CSV
          return ODSExporter.new(collection, exportable_only: exportable_only) if self == ExportFormat::ODS
        end

        def description
          return 'CSV (comma-separated text)' if self == ExportFormat::CSV
          return 'LibreOffice/OpenOffice spreadsheet' if self == ExportFormat::ODS
        end

        def mime_type
          return 'text/csv' if self == ExportFormat::CSV
          return 'application/vnd.oasis.opendocument.spreadsheet' if self == ExportFormat::ODS
        end

        def to_s
          # noinspection RubyYardReturnMatch
          value
        end

        def to_str
          value
        end

        def inspect
          "#{ExportFormat}::#{key}"
        end

        def default?
          self == DEFAULT
        end

        # noinspection RubyYardReturnMatch
        class << self
          # Converts a string or symbol to an {ExportFormat}, or returns
          # an {ExportFormat} if passed on
          #
          # @param format [String, Symbol, ExportFormat] the format
          # @return [ExportFormat] the format
          def ensure_format(format)
            return unless format
            return format if format.is_a?(ExportFormat)

            fmt = ExportFormat.find_by_value(format.to_s.downcase)
            return fmt if fmt

            raise ArgumentError, "Unknown #{ExportFormat}: #{format.inspect}"
          end
        end
      end

    end
  end
end
