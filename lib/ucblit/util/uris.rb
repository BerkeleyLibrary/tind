require 'ucblit/util/uris/appender'

module UCBLIT
  module Util
    module URIs
      class << self
        include URIs
      end

      # Appends the specified paths to the path of the specified URI, removing any extraneous slashes
      # and merging additional query parameters, and returns a new URI with that path and the same scheme,
      # host, query, fragment, etc. as the original.
      #
      # @param uri [URI, String] the original URI
      # @param elements [Array<String, Symbol>] the URI elements to join.
      # @return [URI] a new URI appending the joined path elements.
      # @raise URI::InvalidComponentError if appending the specified elements would create an invalid URI
      def append(uri, *elements)
        Appender.new(uri, *elements).to_uri
      end

      # Returns the specified URL as a URI.
      # @param url [String, URI] the URL.
      # @return [URI] the URI.
      # @raise [URI::InvalidURIError] if `url` cannot be parsed as a URI.
      def uri_or_nil(url)
        return unless url

        url.is_a?(URI) ? url : URI.parse(url.to_s)
      end
    end
  end
end
