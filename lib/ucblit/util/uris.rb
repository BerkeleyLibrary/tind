require 'ucblit/util/paths'
require 'uri'

module UCBLIT
  module Util
    module URIs
      class << self
        include URIs
      end

      QUERY_DELIM = '?'.freeze
      FRAGMENT_DELIM = '#'.freeze
      DELIMS = [QUERY_DELIM, FRAGMENT_DELIM].freeze

      ALL_DELIMS = %w[? & #].freeze

      RFC_DELIMS_RE = /[?#]/.freeze
      ALL_DELIMS_RE = /[#{ALL_DELIMS}]/.freeze

      # Appends the specified paths to the path of the specified URI, removing any extraneous slashes,
      # and returns a new URI with that path and the same scheme, host, query, fragment, etc.
      # as the original.
      #
      # @param uri [URI, String] the original URI
      # @param elements [Array<String, Symbol>] the URI elements to join.
      # @return [URI] a new URI appending the joined path elements.
      def append(uri, *elements)
        require 'ucblit/tind/config'
        raise ArgumentError, 'uri cannot be nil' unless (original_uri = uri_or_nil(uri))

        # TODO: clean this up: URIAppender class?
        path_elements = []
        query_elements = original_uri.query ? [original_uri.query] : []
        fragment_elements = original_uri.fragment ? [original_uri.fragment] : []

        query_start_index = nil
        fragment_start_index = nil

        elem_strs = elements.map(&:to_s)
        elem_strs.each_with_index do |e, i|

          if (q_index = e.index('?'))
            raise URI::InvalidComponentError, "#{e.inspect}: Query delimiter '?' cannot follow fragment delimeter '#'" if fragment_start_index

            unless query_elements.empty?
              raise URI::InvalidComponentError,
                    "#{e.inspect}: URI already has a query string: #{query_elements.join.inspect}"
            end

            q_start = e[(q_index + 1)..]
            if (f_index = q_start.index('#'))
              q_start = q_start[0...f_index]
              elem_strs[i + 1] = "#{q_start[f_index + 1..]}#{elem_strs[i + 1]}"
            end
            query_elements << q_start
            path_elements << e[0...q_index]
            query_start_index = i
          elsif (f_index = e.index('#'))
            unless fragment_elements.empty?
              raise URI::InvalidComponentError,
                    "#{e.inspect}: URI already has a fragment: #{fragment_elements.join.inspect}"
            end

            f_start = e[(f_index + 1)..]
            raise URI::InvalidComponentError, "#{e.inspect}: Query delimiter '?' cannot follow fragment delimeter '#'" if f_start.include?('?')

            fragment_elements << f_start
            (query_start_index ? query_elements : path_elements) << e[0...f_index]
            fragment_start_index = i
          elsif fragment_start_index
            fragment_elements << e
          elsif query_start_index || (e.include?('&') && !query_elements.empty?)
            query_elements << e
          else
            path_elements << e
          end
        end

        original_uri.dup.tap do |new_uri|
          new_uri.path = Paths.join(original_uri.path, *path_elements)
          new_uri.query = query_elements.join unless query_elements.empty?
          new_uri.fragment = fragment_elements.join unless fragment_elements.empty?
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
        return false unless str && %w[& ?].any? { |c| str.start_with?(c) }

        true.tap do |_|
          query = str[1..]
          uri.query = uri.query ? "#{query}&#{uri.query}" : query
        end
      end

    end
  end
end
