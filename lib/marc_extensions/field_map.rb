require 'marc'
module MARCExtensions
  module FieldMapExtensions

    VALID_TAGS = ('000'..'999').freeze

    # Gets the specified fields in order by tag.
    #
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
      reindex unless @clean

      indices_for(tags).map { |i| self[i] }.each(&block)
    end

    private

    def indices_for(tags)
      return all_indices unless tags

      sorted_tag_array(tags)
        .lazy                                      # prevent unnecessary allocations
        .map { |t| @tags[t] }                      # get indices for each tag
        .reject(&:nil?)                            # ignoring any tags we don't have fields for
        .flat_map { |x| x }                        # flatten list of indices -- equiv. Array#flatten
    end

    def all_indices
      [].tap do |a|
        @tags.keys.sort.map do |t|
          a.concat(@tags[t])
        end
      end
    end

    def sorted_tag_array(tags)
      return Array(tags) if tags.is_a?(Range)

      Array(tags).sort
    end

  end
end

module MARC
  # @see https://rubydoc.info/gems/marc/MARC/FieldMap RubyGems documentation
  class FieldMap
    prepend MARCExtensions::FieldMapExtensions
  end
end
