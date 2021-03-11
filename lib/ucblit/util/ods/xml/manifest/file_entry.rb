require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Manifest
          class FileEntry < XML::ElementNode

            attr_reader :full_path
            attr_reader :media_type
            attr_reader :manifest

            def initialize(full_path, media_type = nil, manifest:)
              super(:manifest, 'file-entry', doc: manifest.doc)

              @full_path = full_path
              @media_type = media_type || media_type_for(full_path)
              @manifest = manifest

              set_default_attributes!
            end

            private

            def media_type_for(path)
              return 'application/vnd.oasis.opendocument.spreadsheet' if path == '/'
              return 'text/xml' if path.end_with?('.xml')

              raise ArgumentError, "Can't determine media type for path: #{path.inspect}"
            end

            def set_default_attributes!
              set_attribute('full-path', full_path)
              set_attribute('media-type', media_type)
              set_attribute('version', manifest.version)
            end
          end
        end
      end
    end
  end
end
