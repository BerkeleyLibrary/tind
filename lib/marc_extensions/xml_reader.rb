require 'marc'
require 'marc_extensions/record'

module MARCExtensions
  module XMLReaderClassExtensions
    def read(file, freeze: false)
      new(file, freeze: freeze)
    end
  end
end

module MARC
  # @see https://rubydoc.info/gems/marc/MARC/XMLReader RubyGems documentation
  class XMLReader
    class << self
      prepend MARCExtensions::XMLReaderClassExtensions
    end
  end
end
