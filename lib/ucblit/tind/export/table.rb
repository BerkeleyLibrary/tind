require 'csv'
require 'stringio'

require 'marc_extensions'
require 'ucblit/tind/logging'
require 'ucblit/tind/export/column_group_list'

module UCBLIT
  module TIND
    module Export
      class Table
        include UCBLIT::TIND::Logging

        # ------------------------------------------------------------
        # Accessors

        attr_reader :column_groups

        # ------------------------------------------------------------
        # Initializer

        # Initializes a new Table
        #
        # @param exportable_only [Boolean] whether to filter out non-exportable fields
        # @see Tags
        def initialize(exportable_only: false)
          @column_groups = ColumnGroupList.new(exportable_only: exportable_only)
        end

        # ------------------------------------------------------------
        # Factory method

        class << self
          # Returns a new Table for the provided MARC records.
          #
          # @param records [Enumerable<MARC::Record>] the records
          # @param freeze [Boolean] whether to freeze the table
          # @param exportable_only [Boolean] whether to include only exportable fields
          # @return [Table] the table
          def from_records(records, freeze: false, exportable_only: false)
            Table.new(exportable_only: exportable_only).tap do |table|
              records.each { |r| table << r }
              table.freeze if freeze
            end
          end
        end

        # ------------------------------------------------------------
        # Cell accessors

        def value_at(row, col)
          return unless (column = columns[col])

          column.value_at(row)
        end

        # ------------------------------------------------------------
        # Column accessors

        # The column headers
        #
        # @return [Array<String>] the column headers
        def headers
          columns.map(&:header)
        end

        # The columns
        #
        # @return [Array<Column>] the columns.
        def columns
          # NOTE: this isn't ||= because we only cache on #freeze
          @columns || column_groups.map(&:columns).flatten
        end

        def column_count
          columns.size
        end

        # ------------------------------------------------------------
        # Row / MARC::Record accessors

        def rows
          # NOTE: this isn't ||= because we only cache on #freeze
          @rows || each_row.to_a
        end

        # @yieldparam row [Row] each row
        def each_row
          return to_enum(:each_row) unless block_given?

          (0...row_count).each { |row| yield Row.new(columns, row) }
        end

        # The number of rows (records)
        #
        # @return [Integer] the number of rows
        def row_count
          marc_records.size
        end

        # The MARC records
        #
        # @return [Array<MARC::Record>] the records
        def marc_records
          @marc_records ||= []
        end

        # ------------------------------------------------------------
        # Modifiers

        # Adds the specified record
        #
        # @param marc_record [MARC::Record] the record to add
        def <<(marc_record)
          raise FrozenError, "can't modify frozen MARCTable" if frozen?

          logger.warn('MARC record is not frozen') unless marc_record.frozen?
          column_groups.add_data_fields(marc_record, marc_records.size)
          marc_records << marc_record
          log_record_added(marc_record)

          self
        end

        # ------------------------------------------------------------
        # Object overrides

        def frozen?
          [marc_records, column_groups].all?(&:frozen?) &&
            [@rows, @columns].all? { |d| !d.nil? && d.frozen? }
        end

        def freeze
          [marc_records, column_groups].each(&:freeze)
          @columns ||= columns.freeze
          @rows ||= rows.freeze
          self
        end

        # ------------------------------------------------------------
        # Misc. instance methods

        # TODO: move to UCBLIT::TIND::Export::CSVExporter
        def to_csv(out = nil)
          return write_csv(out) if out

          StringIO.new.tap { |io| write_csv(io) }.string
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def log_record_added(marc_record)
          return logger.info("Added #{marc_record.record_id}: #{row_count} records total") if marc_record
        end

        def write_csv(out)
          csv = out.respond_to?(:write) ? CSV.new(out) : CSV.open(out, 'wb')
          csv << headers
          each_row { |row| csv << row.values }
        end
      end
    end
  end
end
