require 'marc'
require 'marc_extensions/field_map'
require 'marc_extensions/data_field'

module MARCExtensions
  module RecordExtensions

    # Gets the specified fields in order by tag.
    #
    # @see FieldMapExtensions#each_sorted_by_tag
    # @overload each_sorted_by_tag(tags, &block)
    #   Yields each specified field.
    #   @param tags [String, Enumerable<String>] A tag, range of tags, array of tags, or similar
    #   @yieldparam field [MARC::ControlField, MARC::DataField] Each field.
    # @overload each_sorted_by_tag(tags)
    #   An enumerator of the specified variable fields, sorted by tag.
    #   @param tags [String, Enumerable<String>] A tag, range of tags, array of tags, or similar
    #   @return [Enumerator::Lazy<MARC::ControlField, MARC::DataField>] the fields
    # @overload each_sorted_by_tag(&block)
    #   Yields all fields, sorted by tag.
    #   @yieldparam field [MARC::ControlField, MARC::DataField] Each field.
    # @overload each_sorted_by_tag
    #   An enumerator of all fields, sorted by tag.
    #   @return [Enumerator::Lazy<MARC::ControlField, MARC::DataField>] the fields
    def each_sorted_by_tag(tags = nil, &block)
      @fields.each_sorted_by_tag(tags, &block)
    end

    # Gets only the control fields (tag 000-009) from the record. (Note that
    # this method does not protect against pathological records with data
    # fields in the control field range.)
    #
    # @overload each_control_field
    #   An enumerator of the control fields.
    #   @return [Enumerator::Lazy<MARC::ControlField>] the fields
    # @overload each_control_field(&block)
    #   Yields each control field.
    #   @yieldparam field [MARC::ControlField] Each control field.
    def each_control_field(&block)
      each_sorted_by_tag.take_while { |df| df.tag.to_i <= 10 }.each(&block)
    end

    # Gets only the data fields (tag 010-999) from the record. (Note that
    # this method does not protect against pathological records with control
    # fields in the data field range.)
    #
    # @overload each_data_field
    #   An enumerator of the data fields.
    #   @return [Enumerator::Lazy<MARC::DataField>] the fields
    # @overload each_data_field(&block)
    #   Yields each data field.
    #   @yieldparam field [MARC::DataField] Each data field.
    def each_data_field(&block)
      each_sorted_by_tag.select { |df| df.tag.to_i > 10 }.each(&block)
    end

    # Gets the data fields from the record and groups them by tag.
    #
    # @return [Hash<String, Array<MARC::DataField>>] a hash from tags to fields
    def data_fields_by_tag
      # noinspection RubyYardReturnMatch
      each_data_field.with_object({}) { |df, t2df| (t2df[df.tag] ||= []) << df }
    end

    # Gets only the data fields (tag 010-999) from the record. (Note that
    # this method does not protect against pathological records with control
    # fields in the data field range.)
    #
    # @return [Array<DataField>] the data fields.
    def data_fields
      data_fields_by_tag.values.flatten
    end

    # Freezes the leader and fields.
    def freeze
      leader.freeze
      fields.each(&:freeze)
      fields.freeze
      self
    end

    # @return [Boolean] true if the fields and leader are frozen
    def frozen?
      (fields.frozen? && leader.frozen?)
    end

    # TODO: use info from parsed documentation? or move to TIND-specific extension
    def record_id
      cf_001 = self['001']
      return cf_001.value if cf_001
    end
  end
end

module MARC
  # @see https://rubydoc.info/gems/marc/MARC/Record RubyGems documentation
  class Record
    prepend MARCExtensions::RecordExtensions
  end
end
