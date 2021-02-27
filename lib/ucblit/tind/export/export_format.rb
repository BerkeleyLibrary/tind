require 'typesafe_enum'

module UCBLIT
  module TIND
    module Export
      class ExportFormat < TypesafeEnum::Base
        new :CSV
        new :ODS

        DEFAULT = ODS

        def export(collection, out = $stdout)
          return Export.export_csv(collection, out) if self == ExportFormat::CSV
          return Export.export_libreoffice(collection, out) if self == ExportFormat::ODS
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

        class << self
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
