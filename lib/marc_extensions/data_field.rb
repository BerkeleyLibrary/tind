require 'marc'
require 'marc_extensions/subfield'

module MARCExtensions
  module DataFieldExtensions
    def subfield_codes
      subfields.map(&:code)
    end

    def frozen?
      [tag, indicator1, indicator2, subfields].all?(&:frozen?)
      subfields.all?(&:frozen?)
    end

    def freeze
      [tag, indicator1, indicator2].each(&:freeze)
      subfields.each(&:freeze)
      subfields.freeze
      self
    end
  end
end

module MARC
  # @see https://rubydoc.info/gems/marc/MARC/DataField RubyGems documentation
  class DataField
    prepend MARCExtensions::DataFieldExtensions
  end
end
