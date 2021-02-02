require 'marc'
require 'marc_extensions/record'

module MARCExtensions
  module XMLReaderClassExtensions
    def read_frozen(file, options = {})
      MARC::XMLReader.new(file, options).lazy.map { |r| r.tap(&:freeze) }
    end
  end
end

module MARC
  class XMLReader
    class << self
      prepend MARCExtensions::XMLReaderClassExtensions
    end
  end
end
