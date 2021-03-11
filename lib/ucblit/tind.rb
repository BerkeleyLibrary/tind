require 'marc_extensions'
require 'ucblit/util/logging'

Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))

module UCBLIT
  module TIND
    class << self
      include UCBLIT::Util::Logging
    end
  end
end
