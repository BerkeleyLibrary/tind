require 'nokogiri'
require 'ucblit/util/ods/xml/namespace'

module UCBLIT
  module Util
    module ODS
      module XML
        class ElementNode

          # @return [Nokogiri::XML::Document] the document containing this element
          attr_reader :doc

          # @return [Namespace] the namespace for this element
          attr_reader :namespace

          # @return [String] the name of this element
          attr_reader :name

          # @param namespace [String, Symbol, Namespace] the element namespace
          # @param name [String] the element name
          # @param doc [Nokogiri::XML::Document] the document containing this element
          def initialize(namespace, name, doc:)
            @namespace = ensure_namespace(namespace)
            @name = name
            @doc = doc
          end

          def prefix
            namespace.prefix
          end

          def element
            @element ||= create_element
          end

          # rubocop:disable Style/OptionalArguments
          def add_attribute(namespace = prefix, name, value)
            prefix = namespace.to_s == 'xmlns' ? namespace : ensure_namespace(namespace).prefix
            attributes["#{prefix}:#{name}"] = value.to_s
          end
          # rubocop:enable Style/OptionalArguments

          def add_child(child)
            raise ArgumentError, "Not an element: #{child.inspect}" unless child.is_a?(ElementNode)

            child.tap { |c| children << c }
          end

          protected

          def create_element
            doc.create_element("#{prefix}:#{name}", attributes).tap do |element|
              children.each { |child| element.add_child(child.element) }
            end
          end

          # @return [Hash<String, String>] the attributes, as a map from name to value
          def attributes
            # noinspection RubyYardReturnMatch
            @attributes ||= {}
          end

          # @return [Array<ElementNode>] the child elements
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
