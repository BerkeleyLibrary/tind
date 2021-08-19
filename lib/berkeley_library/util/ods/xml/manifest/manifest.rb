require 'berkeley_library/util/ods/xml/element_node'
require 'berkeley_library/util/ods/xml/manifest/file_entry'

module BerkeleyLibrary
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
              add_file_entry(self_file_entry)
            end

            def version
              MANIFEST_VERSION
            end

            # Adds a document to the manifest
            # @param doc [XML::DocumentNode] the document to add
            def add_entry_for(doc)
              FileEntry.new(doc.path, manifest: self).tap { |e| add_file_entry(e) }
            end

            def add_child(child)
              return add_file_entry(child) if child.is_a?(FileEntry)

              child.tap { |c| other_children << c }
            end

            def children
              [file_entries, other_children].flatten
            end

            private

            def self_file_entry
              FileEntry.new('/', manifest: self).tap do |entry|
                entry.set_attribute('version', version)
              end
            end

            def file_entries
              @file_entries ||= []
            end

            def other_children
              @other_children ||= []
            end

            def required_namespaces
              @required_namespaces ||= REQUIRED_NAMESPACES.map { |p| Namespace.for_prefix(p) }
            end

            def add_file_entry(file_entry)
              file_entry.tap { |fe| file_entries << fe }
            end

            def set_default_attributes!
              required_namespaces.each { |ns| set_attribute(:xmlns, ns.prefix, ns.uri) }
              set_attribute('version', version)
            end
          end
        end
      end
    end
  end
end
