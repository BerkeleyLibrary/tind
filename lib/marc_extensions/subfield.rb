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
  class Subfield
    prepend MARCExtensions::SubfieldExtensions
  end
end
