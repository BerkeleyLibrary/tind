require 'marc'

module MARCExtensions
  module SubfieldExtensions
    def frozen?
      [code, value].all?(&:frozen?)
    end

    def freeze
      [code, value].each(&:freeze)
      self
    end
  end
end

module MARC
  # @see https://rubydoc.info/gems/marc/MARC/Subfield RubyGems documentation
  class Subfield
    prepend MARCExtensions::SubfieldExtensions
  end
end
