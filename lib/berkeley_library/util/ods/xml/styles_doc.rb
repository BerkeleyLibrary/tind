require 'nokogiri'
require 'berkeley_library/util/ods/xml/document_node'
require 'berkeley_library/util/ods/xml/office/document_styles'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        class StylesDoc < DocumentNode

          def initialize
            super('styles.xml')
          end

          def root_element_node
            document_styles
          end

          def document_styles
            @document_styles ||= Office::DocumentStyles.new(doc: doc)
          end
        end
      end
    end
  end
end
