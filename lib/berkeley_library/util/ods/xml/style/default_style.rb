require 'berkeley_library/util/ods/xml/element_node'
require 'berkeley_library/util/ods/xml/style/family'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class DefaultStyle < XML::ElementNode

            attr_reader :family

            def initialize(family, doc:)
              super(:style, 'default-style', doc: doc)

              @family = Family.ensure_family(family)

              set_default_attributes!
            end

            private

            def set_default_attributes!
              set_attribute('family', family)
            end
          end
        end
      end
    end
  end
end
