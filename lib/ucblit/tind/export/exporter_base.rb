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

        # @return [Boolean] whether to include only exportable fields
        attr_reader :exportable_only

        # ------------------------------------------------------------
        # Initializer

        # Initializes a new exporter
        #
        # @param collection [String] The collection name
        # @param exportable_only [Boolean] whether to include only exportable fields
        def initialize(collection, exportable_only: true)
          @collection = collection
          @exportable_only = exportable_only
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
            Export::Table.from_records(results, freeze: true, exportable_only: exportable_only)
          end
        end

      end
    end
  end
end
