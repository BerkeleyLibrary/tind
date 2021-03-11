require 'nokogiri'
require 'ucblit/util/ods/xml/document_node'
require 'ucblit/util/ods/xml/office/document_content'

module UCBLIT
  module Util
    module ODS
      module XML
        class ContentDoc < DocumentNode
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
