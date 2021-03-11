require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class DocumentStyles < XML::ElementNode
            REQUIRED_NAMESPACES = %i[office style].freeze

            def initialize(doc:)
              super(:office, 'document-styles', doc: doc)

              set_default_attributes!
            end

            private

            def required_namespaces
              @required_namespaces ||= REQUIRED_NAMESPACES.map { |p| Namespace.for_prefix(p) }
            end

            def set_default_attributes!
              required_namespaces.each { |ns| set_attribute(:xmlns, ns.prefix, ns.uri) }
            end
          end
        end
      end
    end
  end
end
