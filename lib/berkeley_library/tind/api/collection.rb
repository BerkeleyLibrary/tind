require 'json'
require 'berkeley_library/logging'
require 'berkeley_library/tind/api/api_exception'

module BerkeleyLibrary
  module TIND
    module API
      class Collection
        attr_reader :name, :nb_rec, :children, :translations
        alias size nb_rec

        def initialize(name, nb_rec, children, translations)
          @name = name
          @nb_rec = nb_rec
          @children = children
          @translations = translations
        end

        def name_en
          return unless (names = translations['name'])

          names['en']
        end

        def each_descendant(include_self: false, &block)
          yield self if include_self

          children.each { |c| c.each_descendant(include_self: include_self, &block) }
        end

        class << self
          include BerkeleyLibrary::Logging

          ENDPOINT = 'collections'.freeze

          def all
            json = API.get(ENDPOINT, depth: 100)
            all_from_json(json)
          rescue API::APIException => e
            logger.error(e)
            []
          end

          def each_collection(&block)
            return to_enum(:each_collection) unless block_given?

            all.each { |c| c.each_descendant(include_self: true, &block) }
          end

          # Returns an array of collection tree roots, which can be traversed
          # with {Collection#each_descendant}.
          #
          # @return [Array<Collection>] an array of top-level collections
          def all_from_json(json)
            ensure_hash(json).map do |name, attrs|
              translations = attrs['translations']
              Collection.new(
                name,
                attrs['nb_rec'],
                all_from_json(attrs['children']),
                translations
              )
            end
          end

          private

          def ensure_hash(json)
            return {} unless json
            return json if hash_like?(json)

            JSON.parse(json)
          end

          def hash_like?(h)
            h.respond_to?(:each_key) && h.respond_to?(:each_value)
          end
        end
      end
    end
  end
end
