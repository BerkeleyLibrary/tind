require 'typesafe_enum'
require 'ucblit/tind/export/csv_exporter'
require 'ucblit/tind/export/ods_exporter'

module UCBLIT
  module TIND
    module Export
      class ExportFormat < TypesafeEnum::Base
        new :CSV
        new :ODS

        DEFAULT = ODS

        def export(collection, out = $stdout)
          raise ArgumentError, "Don't know how to export #{self}" unless (exporter = exporter_for(collection))

          exporter.export(out)
        end

        def description
          return 'CSV (comma-separated text)' if self == ExportFormat::CSV
          return 'LibreOffice/OpenOffice spreadsheet' if self == ExportFormat::ODS
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

        class << self
          def ensure_format(format)
            return unless format
            return format if format.is_a?(ExportFormat)

            fmt = ExportFormat.find_by_value(format.to_s.downcase)
            return fmt if fmt

            raise ArgumentError, "Unknown #{ExportFormat}: #{format.inspect}"
          end
        end

        private

        def exporter_for(collection)
          return CSVExporter.new(collection) if self == ExportFormat::CSV
          return ODSExporter.new(collection) if self == ExportFormat::ODS
        end
      end

    end
  end
end
