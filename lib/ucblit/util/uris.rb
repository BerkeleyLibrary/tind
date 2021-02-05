require 'ucblit/util/paths'
require 'uri'

module UCBLIT
  module Util
    module URIs
      class << self
        include URIs
      end

      # Appends the specified paths to the path of the specified URI, removing any extraneous slashes,
      # and returns a new URI with that path and the same scheme, host, query, fragment, etc.
      # as the original.
      #
      # @param uri [URI, String] the original URI
      # @param elements [Array<String>] the URI elements to join.
      # @return [URI] a new URI appending the joined path elements.
      def append(uri, *elements)
        original_uri = uri_or_nil(uri)
        original_path = original_uri.path

        original_uri.dup.tap do |new_uri|
          path = UCBLIT::Util::Paths.join(original_path, *elements)
          (path.size - 1).downto(0).each do |i|
            next unless apply_fragment?(new_uri, path[i..]) || apply_query?(new_uri, path[i..])

            path.slice!(i..)
          end
          new_uri.path = path
        end
      end

      # Returns the specified URL as a URI.
      # @param url [String, URI] the URL.
      # @return [URI] the URI.
      # @raise [URI::InvalidURIError] if `url` cannot be parsed as a URI.
      def uri_or_nil(url)
        return unless url

        url.is_a?(URI) ? url : URI.parse(url.to_s)
      end

      private

      def apply_fragment?(uri, str)
        return false unless str&.start_with?('#')

        fragment = str[1..]
        true.tap do |_|
          raise URI::InvalidComponentError, "Too many URL fragments: #{[uri.fragment, fragment].map(&:inspect)}" if uri.fragment

          # if fragment is empty, don't set it but still strip `#`
          uri.fragment = fragment unless fragment == ''
        end
      end

      def apply_query?(uri, str)
        return false unless str&.start_with?('?')

        query = str[1..]
        true.tap do |_|
          raise URI::InvalidComponentError, "Too many query strings: #{[uri.query, query].map(&:inspect)}" if uri.query

          # if query is empty, don't set it but still strip `?`
          uri.query = query unless query == ''
        end
      end

    end
  end
end
