require 'typesafe_enum'

module UCBLIT
  module Util
    module ODS
      module XML

        class Namespace < TypesafeEnum::Base
          new :CALCEXT, 'urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0'
          new :CHART, 'urn:oasis:names:tc:opendocument:xmlns:chart:1.0'
          new :DR3D, 'urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0'
          new :FIELD, 'urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0'
          new :FO, 'urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0'
          new :FORM, 'urn:oasis:names:tc:opendocument:xmlns:form:1.0'
          new :LOEXT, 'urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0'
          new :MANIFEST, 'urn:oasis:names:tc:opendocument:xmlns:manifest:1.0'
          new :META, 'urn:oasis:names:tc:opendocument:xmlns:meta:1.0'
          new :OF, 'urn:oasis:names:tc:opendocument:xmlns:of:1.2'
          new :OFFICE, 'urn:oasis:names:tc:opendocument:xmlns:office:1.0'
          new :PRESENTATION, 'urn:oasis:names:tc:opendocument:xmlns:presentation:1.0'
          new :SCRIPT, 'urn:oasis:names:tc:opendocument:xmlns:script:1.0'
          new :STYLE, 'urn:oasis:names:tc:opendocument:xmlns:style:1.0'
          new :SVG, 'urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0'
          new :TABLE, 'urn:oasis:names:tc:opendocument:xmlns:table:1.0'
          new :TEXT, 'urn:oasis:names:tc:opendocument:xmlns:text:1.0'

          def prefix
            key.to_s.downcase
          end

          def uri
            value
          end

          def attr(name, value)
            { "#{prefix}:#{name}" => value }
          end

          def to_str
            prefix
          end

          class << self
            def as_attributes
              {}.tap do |attrs|
                Namespace.each do |ns|
                  attrs["xmlns:#{ns.prefix}"] = ns.uri
                end
              end
            end

            def for_prefix(prefix)
              @by_prefix ||= Namespace.map { |ns| [ns.prefix, ns] }.to_h
              @by_prefix[prefix.to_s]
            end
          end
        end

      end
    end
  end
end
