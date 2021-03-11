require 'nokogiri'
require 'ucblit/util/ods/xml/document_node'
require 'ucblit/util/ods/xml/manifest/manifest'

module UCBLIT
  module Util
    module ODS
      module XML
        class ManifestDoc < DocumentNode

          def initialize
            super('META-INF/manifest.xml')
          end

          def root_element_node
            manifest
          end

          def manifest
            @manifest ||= Manifest::Manifest.new(manifest_doc: self)
          end
        end
      end
    end
  end
end
