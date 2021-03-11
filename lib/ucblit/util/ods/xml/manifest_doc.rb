require 'nokogiri'
require 'ucblit/util/ods/xml/document_node'
require 'ucblit/util/ods/xml/manifest/manifest'

module UCBLIT
  module Util
    module ODS
      module XML
        class ManifestDoc < DocumentNode
          def root_element_node
            manifest
          end

          def manifest
            @manifest ||= Manifest::Manifest.new(doc: doc)
          end
        end
      end
    end
  end
end
