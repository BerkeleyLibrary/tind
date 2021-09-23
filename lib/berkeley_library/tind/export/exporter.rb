require 'berkeley_library/logging'
require 'berkeley_library/tind/api/search'
require 'berkeley_library/tind/export/table'

module BerkeleyLibrary
  module TIND
    module Export

      # Superclass of exporters for different formats
      class Exporter
        include BerkeleyLibrary::Logging

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
        # Abstract methods

        # Exports the collection
        # @param out [IO, String, Pathname, nil] the IO or file path to write the
        #   exported data to, or nil to return a string
        # rubocop:disable Lint/UnusedMethodArgument
        def export(out = nil)
          # This is a stub, used for documentation
          raise NoMethodError, "#{self.class} does not implement `export`"
        end
        # rubocop:enable Lint/UnusedMethodArgument

        # ------------------------------------------------------------
        # Accessors

        # Returns true if the collection can be exported, false otherwise.
        # Note that this requires reading the collection data from the TIND
        # server; failures will be fast but success may be slow. (On the other
        # hand, the retrieved collection data is cached, so the subsequent
        # export will not need to retrieve it again.)
        def any_results?
          !_export_table.empty?
        end

        # ------------------------------------------------------------
        # Object overrides

        def respond_to?(*args)
          return false if instance_of?(Exporter) && (args && args.first.to_s == 'export')

          super
        end

        # ------------------------------------------------------------
        # Protected methods

        protected

        # Returns a table of all records in the specified
        # collection
        #
        # @return [Export::Table] the table
        # @raise NoResultsError if no search results were returned for the collection
        def export_table
          # TODO: something more clever. Search.has_results?
          return _export_table unless _export_table.empty?

          raise no_results_error
        end

        private

        def no_results_error
          NoResultsError.new("No records returned for collection #{collection.inspect}")
        end

        def _export_table
          @_export_table ||= begin
            logger.info("Reading collection #{collection.inspect}")
            results = API::Search.new(collection: collection).each_result(freeze: true)

            logger.info('Creating export table')
            # noinspection RubyYardParamTypeMatch
            Export::Table.from_records(results, freeze: true, exportable_only: exportable_only)
          end
        end

      end
    end
  end
end
