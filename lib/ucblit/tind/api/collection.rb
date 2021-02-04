require 'ucblit/tind/config'
require 'json'

module UCBLIT
  module TIND
    module API
      class Collection

        attr_reader :name, :size, :children

        def initialize(name, size, children)
          @name = name
          @size = size
          @children = children
        end

        class << self
          include UCBLIT::TIND::Config

          def all
            json = API.get(:collection, depth: 100)
            all_from_json(json)
          end

          def all_from_json(json)
            ensure_hash(json).each map do |name, attrs|
              Collection.new(name, attrs['nb_rec'], all_from_json(attrs['children']))
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
