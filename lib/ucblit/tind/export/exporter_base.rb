require 'ucblit/tind/logging'
require 'ucblit/tind/api/search'
require 'ucblit/tind/export/table'

module UCBLIT
  module TIND
    module Export

      # Superclass of exporters for different formats
      class ExporterBase
        include UCBLIT::TIND::Logging

        # ------------------------------------------------------------
        # Accessors

        # @return [String] the collection name
        attr_reader :collection

        # ------------------------------------------------------------
        # Initializer

        # Initializes a new exporter
        #
        # @overload initialize(collection)
        #   Initializes an exporter that will return a string.
        #   @param collection [String] The collection name
        #   @param format [ExportFormat, String, Symbol] the export format
        # @overload initialize(collection, out)
        #   Initialies an exporter that will write to the specified output stream.
        #   @param collection [String] The collection name
        #   @param out [IO] the output stream
        # @overload initialize(collection, path)
        #   Initialies an exporter that will write to the specified output file.
        #   @param collection [String] The collection name
        #   @param path [String, Pathname] the path to the output file
        def initialize(collection) # TODO: add filtering
          @collection = collection
        end

        # ------------------------------------------------------------
        # Protected methods

        protected

        # Creates a table of all records in the specified
        # collection
        #
        # @return [Export::Table] the table
        def export_table
          @export_table ||= begin
            logger.info("Reading collection #{collection.inspect}")
            search = API::Search.new(collection: collection)
            results = search.each_result(freeze: true)

            logger.info('Creating export table')
            # noinspection RubyYardParamTypeMatch
            Export::Table.from_records(results, freeze: true)
          end
        end

      end
    end
  end
end
