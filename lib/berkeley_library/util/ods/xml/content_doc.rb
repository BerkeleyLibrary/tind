require 'nokogiri'
require 'berkeley_library/util/ods/xml/document_node'
require 'berkeley_library/util/ods/xml/office/document_content'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        class ContentDoc < DocumentNode

          def initialize
            super('content.xml')
          end

          def root_element_node
            document_content
          end

          def document_content
            @document_content ||= Office::DocumentContent.new(doc: doc)
          end
        end
      end
    end
  end
end
