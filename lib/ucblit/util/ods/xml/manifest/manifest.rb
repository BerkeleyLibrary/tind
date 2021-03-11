require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/manifest/file_entry'

module UCBLIT
  module Util
    module ODS
      module XML
        module Manifest
          class Manifest < XML::ElementNode
            REQUIRED_NAMESPACES = [:manifest].freeze
            MANIFEST_VERSION = '1.2'.freeze

            def initialize(doc:)
              super(:manifest, 'manifest', doc: doc)

              set_default_attributes!
              add_default_children!
            end

            def version
              MANIFEST_VERSION
            end

            private

            def required_namespaces
              @required_namespaces ||= REQUIRED_NAMESPACES.map { |p| Namespace.for_prefix(p) }
            end

            def set_default_attributes!
              required_namespaces.each { |ns| set_attribute(:xmlns, ns.prefix, ns.uri) }
              set_attribute('version', version)
            end

            def add_default_children!
              children << FileEntry.new('/', manifest: self)
              children << FileEntry.new('content.xml', manifest: self)
              children << FileEntry.new('styles.xml', manifest: self)
            end
          end
        end
      end
    end
  end
end
