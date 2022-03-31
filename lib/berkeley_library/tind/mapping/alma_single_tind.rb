require 'marc'
require 'berkeley_library/tind'
require 'berkeley_library/alma'

module BerkeleyLibrary
  module TIND
    module Mapping
      class AlmaSingleTIND
        include Util
        include AlmaBase
        include BerkeleyLibrary::Logging

        def initialize; end

        # id can be
        # 1) Alma mms id
        # 2) Oskicat No
        # 3) BarCode No
        # If alma record is nil or un-qualified, it returns nil
        # Input datafields - an array of record specific datafields:  for example, fft datafields, datafield 035 etc.
        def record(id, datafields)
          base_tind_record(id, datafields)
        end

      end
    end
  end
end
