require 'ucblit/util/paths'
require 'uri'

module UCBLIT
  module Util
    module URIs
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
          (path.size - 1).downto(0).each { |i| path = extract_fragments_and_queries(new_uri, path, i) }
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

      class << self
        include URIs
      end

      private

      # TODO: clean this up
      def extract_fragments_and_queries(new_uri, path, index)
        return path unless %w[# ?].include?(path[i])

        case path[index]
        when '#'
          raise URI::InvalidComponentError, "Too many URI fragments: #{new_uri.fragment}, #{path[i..]}" if new_uri.fragment

          new_uri.fragment = path[index + 1..]
        when '?'
          raise URI::InvalidComponentError, "Too many query strings: #{new_uri.query}, #{path[i..]}" if new_uri.query

          new_uri.query = path[index + 1..]
        end
        path[0...index]
      end

    end
  end
end
