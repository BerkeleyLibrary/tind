require 'marc'
module MARCExtensions
  module FieldMapExtensions

    VALID_TAGS = ('000'..'999').freeze

    # Gets the specified fields in order by tag.
    #
    # @overload each_sorted_by_tag(tags)
    #   An enumerator of the specified variable fields.
    #   @param tags [String, Enumerable<String>] A tag, range of tags, array of tags, or similar
    #   @return [Enumerator::Lazy<MARC::ControlField, MARC::DataField>] the fields
    # @overload each_sorted_by_tag(tags, &block)
    #   Yields each specified field.
    #   @param tags [String, Enumerable<String>] A tag, range of tags, array of tags, or similar
    #   @yieldparam field [MARC::ControlField, MARC::DataField] Each field.
    def each_sorted_by_tag(tags, &block)
      reindex unless @clean

      indices_for(tags).map { |i| self[i] }.each(&block)
    end

    private

    def indices_for(tags)
      (tags.is_a?(Range) ? tags : Array(tags).sort)
        .lazy                                      # prevent unnecessary allocations
        .take_while { |t| VALID_TAGS.include?(t) } # don't iterate ranges beyond valid tag range
        .map { |t| @tags[t] }                      # get indices for each tag
        .reject(&:nil?)                            # ignoring any tags we don't have fields for
        .flat_map { |x| x }                        # flatten list of indices -- equiv. Array#flatten
    end
  end
end

module MARC
  # @see https://rubydoc.info/gems/marc/MARC/FieldMap RubyGems documentation
  class FieldMap
    prepend MARCExtensions::FieldMapExtensions
  end
end
