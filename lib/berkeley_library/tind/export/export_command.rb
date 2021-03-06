require 'optparse'

require 'berkeley_library/tind/api'
require 'berkeley_library/tind/config'
require 'berkeley_library/tind/export/export'
require 'berkeley_library/tind/export/export_format'
require 'berkeley_library/logging'
require 'berkeley_library/util/sys_exits'

module BerkeleyLibrary
  module TIND
    module Export
      # rubocop:disable Metrics/ClassLength
      class ExportCommand
        include BerkeleyLibrary::Util::SysExits

        attr_reader :options
        attr_reader :out

        def initialize(*args, out: $stdout)
          @options = ExportCommand.parse_options(args)
          @out = out
        end

        def execute!
          return list_collections if options[:list]

          export_collection
        rescue StandardError => e
          warn(e)
          warn(e.backtrace.join("\n")) if e.backtrace && options[:verbose]

          exit(EX_SOFTWARE)
        end

        private

        def list_collections
          BerkeleyLibrary::TIND::API::Collection.each_collection { |c| out.puts "#{c.nb_rec}\t#{c.name}" }
        end

        def export_collection
          BerkeleyLibrary::TIND::Export.export(
            options[:collection],
            options[:format],
            options[:outfile] || out
          )
        end

        class << self
          include BerkeleyLibrary::Util::SysExits

          DEFAULT_FORMAT = ExportFormat::CSV
          FORMATS = ExportFormat.to_a.map(&:value).join(', ')
          OPTS = {
            f: ['--format FORMAT', "Format (#{FORMATS}; defaults to output file extension, or else to #{DEFAULT_FORMAT})"],
            o: ['--output-file FILE', 'Output file or directory'],
            l: ['--list-collections', 'List collection sizes and names'],
            u: ['--tind-base-url URL', "TIND base URL (default $#{BerkeleyLibrary::TIND::Config::ENV_TIND_BASE_URL})"],
            k: ['--api-key KEY', "TIND API key (default $#{BerkeleyLibrary::TIND::Config::ENV_TIND_API_KEY})"],
            e: ['--env-file [ENV]', 'Read environment variables from <ENV> (default: ./.env)'],
            v: ['--verbose', 'Verbose error logging'],
            h: ['--help', 'Show help and exit']
          }.freeze

          def parse_options(argv)
            {}.tap do |opts|
              option_parser(opts).parse!(argv)
              opts[:collection] = argv.pop
              opts[:format] = ensure_format(opts)
              validate!(opts)
              configure!(opts)
            end
          rescue StandardError => e
            print_usage_and_exit!($stderr, EX_USAGE, e.message)
          end

          private

          def validate!(opts)
            return if opts[:list]
            raise ArgumentError, 'Collection not specified' unless opts[:collection]
            raise ArgumentError, 'OpenOffice/LibreOffice export requires a filename' if opts[:format] == ExportFormat::ODS && !opts[:outfile]
          end

          def configure!(opts)
            configure_env(opts)
            BerkeleyLibrary::TIND::Config.base_uri = opts[:tind_base_url] if opts[:tind_base_url]
            BerkeleyLibrary::TIND::Config.api_key = opts[:api_key] if opts[:api_key]
            BerkeleyLibrary::Logging.logger = configure_logger(opts)
          end

          def configure_logger(opts)
            return Logger.new(File::NULL) unless opts[:verbose]

            # TODO: simpler log format? different log levels?
            BerkeleyLibrary::Logging::Loggers.new_readable_logger($stderr).tap { |logger| logger.level = Logger::DEBUG }
          end

          def configure_env(opts)
            return unless (env_file = opts[:env_file])

            warn "Reading environment from #{env_file}" if opts[:verbose]

            require 'dotenv'
            Dotenv.load(env_file)
          end

          def ensure_format(opts)
            fmt = opts[:format] || (File.extname(opts[:outfile]).sub(/^\./, '') if opts[:outfile])
            return DEFAULT_FORMAT unless fmt

            ExportFormat.ensure_format(fmt)
          end

          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def option_parser(opts = {})
            OptionParser.new do |p|
              p.summary_indent = ' '
              p.on('-f', *OPTS[:f]) { |fmt| opts[:format] = fmt }
              p.on('-o', *OPTS[:o]) { |out| opts[:outfile] = out }
              p.on('-l', *OPTS[:l]) { opts[:list] = true }
              p.on('-u', *OPTS[:u]) { |url| opts[:tind_base_url] = url }
              p.on('-k', *OPTS[:k]) { |k| opts[:api_key] = k }
              p.on('-e', *OPTS[:e]) { |e| opts[:env_file] = env_file_path(e) }
              p.on('-v', *OPTS[:v]) { opts[:verbose] = true }
              p.on('-h', *OPTS[:h]) { print_usage_and_exit! }
            end
          end
          # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

          def env_file_path(env_file_opt)
            File.realpath(env_file_opt || File.join(Dir.pwd, '.env'))
          end

          def print_usage_and_exit!(out = $stdout, exit_code = EX_OK, msg = nil)
            out.puts("#{msg}\n\n") if msg
            out.puts(usage)
            exit(exit_code)
          end

          def usage
            <<~USAGE
              Usage: tind-export [options] COLLECTION

              Options:
                #{summarize_options}

              Examples:
                1. list collections
                   tind-export --list-collections
                2. export a collection as an OpenOffice/LibreOffice spreadsheet
                   tind-export -o lincoln-papers.ods 'Abraham Lincoln Papers'
                3. export a collection as an OpenOffice/LibreOffice spreadsheet in exploded XML format,
                   where `lincoln-papers` is a directory
                   tind-export -v -f ODS -o lincoln-papers 'Abraham Lincoln Papers'
            USAGE
          end

          def summarize_options
            option_parser.summarize.join('  ')
          end
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
