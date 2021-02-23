require 'optparse'

require 'ucblit/tind/api'
require 'ucblit/tind/config'
require 'ucblit/tind/export/export'
require 'ucblit/tind/export/export_format'

module UCBLIT
  module TIND
    module Export
      class ExportCommand

        attr_reader :options

        def initialize(argv = ARGV)
          @options = ExportCommand.parse_options(argv)
        end

        def execute!
          return list_collection_names if options[:list]

          export_collection
        rescue StandardError => e
          warn(e)
          warn(e.backtrace.join("\n")) if e.backtrace && options[:verbose]
        end

        private

        def list_collection_names
          UCBLIT::TIND::API::Collection.each_collection { |c| puts c.name }
        end

        def export_collection
          UCBLIT::TIND::Export.export(
            options[:collection],
            options[:format],
            options[:outfile] || $stdout
          )
        end

        class << self

          DEFAULT_FORMAT = ExportFormat::CSV

          def parse_options(argv)
            opts = {}
            option_parser(opts).parse!(argv)
            opts[:collection] = argv.pop
            opts[:format] = ensure_format(opts)

            valid_options(opts)
          rescue StandardError => e
            print_usage_and_exit!($stderr, -1, e.message)
          end

          private

          def valid_options(options)
            options.tap do |opts|
              next if options[:list]
              raise ArgumentError, 'Collection not specified' unless opts[:collection]
              raise ArgumentError, 'OpenOffice/LibreOffice export requires a filename' if opts[:format] == ExportFormat::ODS && !opts[:outfile]

              configure!(opts)
            end
          end

          def configure!(opts)
            UCBLIT::TIND::Config.base_uri = opts[:tind_base_url] if opts[:tind_base_url]
            UCBLIT::TIND::API.api_key = opts[:api_key] if opts[:api_key]
            UCBLIT::TIND.logger = configure_logger(opts)
          end

          def configure_logger(opts)
            return Logger.new(File::NULL) unless opts[:verbose]

            # TODO: simpler log format?
            UCBLIT::Logging::Loggers.new_readable_logger($stderr).tap do |logger|
              # TODO: support different log levels?
              logger.level = Logger::DEBUG
            end
          end

          def ensure_format(opts)
            fmt = opts[:format] || (File.extname(opts[:outfile]).sub(/^\./, '') if opts[:outfile])
            return DEFAULT_FORMAT unless fmt

            ExportFormat.ensure_format(fmt)
          end

          def option_parser(opts = {})
            formats = ExportFormat.to_a.map(&:value).join(', ')
            OptionParser.new do |p|
              p.summary_indent = ' '
              p.on('-f', '--format FORMAT', "Format (#{formats}; defaults to output file extension, or else to #{DEFAULT_FORMAT})") do |fmt|
                opts[:format] = fmt
              end
              p.on('-o', '--output-file FILE', 'Output file') { |out| opts[:outfile] = out }
              p.on('-l', '--list-collections', 'List collection names') { opts[:list] = true }
              p.on('-u', '--tind-base-url URL', "TIND base URL (default $#{UCBLIT::TIND::Config::ENV_TIND_BASE_URL})") do |url|
                opts[:tind_base_url] = url
              end
              p.on('-k', '--api-key KEY', "TIND API key (default $#{UCBLIT::TIND::API::ENV_TIND_API_KEY})") { |k| opts[:api_key] = k }
              p.on('-v', '--verbose', 'Verbose error logging') { opts[:verbose] = true }
              p.on('-h', '--help', 'Show help and exit') { print_usage_and_exit! }
            end
          end

          def print_usage_and_exit!(out = $stdout, exit_code = 0, msg = nil)
            out.puts("#{msg}\n\n") if msg
            out.puts(usage)
            raise SystemExit, exit_code
          end

          def usage
            <<~USAGE
              Usage: tind-export [options] COLLECTION

              Options:
                #{summarize_options}

              Examples:
                tind-export --list-collections
                tind-export -f ODS -o lincoln-papers.ods 'Abraham Lincoln Papers'
            USAGE
          end

          def summarize_options
            option_parser.summarize.join('  ')
          end
        end
      end
    end
  end
end
