require 'ucblit/tind/api/search/parameters'

module UCBLIT
  module TIND
    module API
      module Search
        class << self
          include UCBLIT::TIND::Config

          def perform_search(params)
            response = API.get(:search, params.to_params)
            # TODO: handle pagination
            # TODO: handle other content types
            response.body.to_s
          rescue HTTP::ResponseError => e
            logger.error(e)
            ''
          end
        end
      end
    end
  end
end
