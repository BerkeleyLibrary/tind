require 'nokogiri'
require 'berkeley_library/util/ods/xml/document_node'
require 'berkeley_library/util/ods/xml/manifest/manifest'

module BerkeleyLibrary
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
            @manifest ||= Manifest::Manifest.new(doc: doc)
          end
        end
      end
    end
  end
end
