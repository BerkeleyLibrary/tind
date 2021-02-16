require 'ucblit/tind/api/search'

module UCBLIT
  module TIND
    module Exporter
      class << self
        def export(collection, out = $stdout)
          search = API::Search.new(collection: collection)
          results = search.each_result(freeze: true)
          table = Export::Table.from_records(results, freeze: true)
          table.to_csv(out)
        end
      end
    end
  end
end
