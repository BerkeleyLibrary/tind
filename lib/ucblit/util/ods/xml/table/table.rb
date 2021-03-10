require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/loext/table_protection'

module UCBLIT
  module Util
    module ODS
      module XML
        module Table
          class Table < XML::ElementNode
            attr_reader :name

            def initialize(name, doc:, protected: true)
              super(:table, 'table', doc: doc)

              @name = name
              @protected = protected

              add_default_attributes!
              add_default_elements!
            end

            def protected?
              @protected
            end

            private

            def add_default_attributes!
              add_attribute('name', name)
              # TODO: style
              add_attribute('protected', 'true') if protected?
            end

            def add_default_elements!
              children << LOExt::TableProtection.new(doc: doc) if protected?
            end
          end
        end
      end
    end
  end
end
