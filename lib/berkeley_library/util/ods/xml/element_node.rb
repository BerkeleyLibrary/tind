require 'nokogiri'
require 'berkeley_library/logging'
require 'berkeley_library/util/ods/xml/namespace'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        class ElementNode
          include BerkeleyLibrary::Logging

          # @return [Nokogiri::XML::Document] the document containing this element
          attr_reader :doc

          # @return [Namespace] the namespace for this element
          attr_reader :namespace

          # @return [String] the name of this element
          attr_reader :element_name

          # @param namespace [String, Symbol, Namespace] the element namespace
          # @param element_name [String] the element name
          # @param doc [Nokogiri::XML::Document] the document containing this element
          def initialize(namespace, element_name, doc:)
            @namespace = ensure_namespace(namespace)
            @element_name = element_name
            @doc = doc
          end

          def prefix
            namespace.prefix
          end

          def element
            ensure_element!
          end

          # Finalize this XML element and prepare for output.
          def ensure_element!
            @element ||= create_element
          end

          # rubocop:disable Style/OptionalArguments
          def set_attribute(namespace = prefix, name, value)
            attr_name = prefixed_attr_name(namespace, name)
            attributes[attr_name] = value.to_s
          end
          # rubocop:enable Style/OptionalArguments

          # rubocop:disable Style/OptionalArguments
          def clear_attribute(namespace = prefix, name)
            attr_name = prefixed_attr_name(namespace, name)
            attributes.delete(attr_name)
          end
          # rubocop:enable Style/OptionalArguments

          def add_child(child)
            raise ArgumentError, "Not text or an element: #{child.inspect}" unless child.is_a?(ElementNode) || child.is_a?(String)

            child.tap { |c| children << c }
          end

          protected

          def prefixed_attr_name(ns, name)
            return "xmlns:#{name}" if ns.to_s == 'xmlns'

            "#{ensure_namespace(ns).prefix}:#{name}"
          end

          def create_element
            doc.create_element("#{prefix}:#{element_name}", attributes).tap do |element|
              children.each do |child|
                next element.add_child(child.element) if child.is_a?(ElementNode)

                text_node = doc.create_text_node(child.to_s)
                element.add_child(text_node)
              end
            end
          end

          # @return [Hash<String, String>] the attributes, as a map from name to value
          def attributes
            # noinspection RubyYardReturnMatch
            @attributes ||= {}
          end

          # @return [Array<ElementNode>] the child elements
          # TODO: replace this with :each_child and a protected default array
          def children
            @children ||= []
          end

          private

          def ensure_namespace(ns)
            return ns if ns.is_a?(Namespace)
            raise ArgumentError, "Not a recognized namespace: #{ns.inspect}" unless (ns_for_prefix = Namespace.for_prefix(ns.to_s.downcase))

            ns_for_prefix
          end
        end
      end
    end
  end
end
