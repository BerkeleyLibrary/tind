require 'berkeley_library/util/ods/xml/element_node'
require 'berkeley_library/util/ods/xml/style/family'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Style
          class Style < XML::ElementNode
            include Comparable

            attr_reader :style_name, :family

            def initialize(style_name, family, doc:)
              super(:style, 'style', doc: doc)

              @style_name = style_name
              @family = Family.ensure_family(family)

              set_default_attributes!
            end

            def <=>(other)
              return 0 if other.equal?(self)
              return nil unless other.instance_of?(self.class)

              s_index, o_index = [style_name, other.style_name].map { |n| family.index_part(n) }
              return style_name <=> other.style_name unless s_index && o_index

              s_index <=> o_index
            end

            private

            def set_default_attributes!
              set_attribute('name', style_name)
              set_attribute('family', family)
            end
          end
        end
      end
    end
  end
end
