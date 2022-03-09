require 'marc'
require 'berkeley_library/tind'
require 'berkeley_library/alma'
module BerkeleyLibrary
  module TIND
    module Mapping

      class AlmaMultipleTIND
        include Util
        include AlmaBase
        include BerkeleyLibrary::Logging

        # id can be
        # 1) Alma mms id
        # 2) Oskicat No
        # 3) BarCode No
        def initialize(id)
          @id = id
          @marc_record = alma_record(id)
        end

        # If alma record is nil or un-qualified, it returns nil
        # Input datafields - an array of record specific datafields:  for example, fft datafields, datafield 035 etc.
        def record(datafields)
          base_tind_record(@id, datafields, @marc_record)
        end

        # This is mainly for testing purpose, each collection can have a function to save it's record
        def save_tind_record_to_file(tind_record, file)
          base_save(@id, tind_record, file)
        end

      end
    end
  end
end
