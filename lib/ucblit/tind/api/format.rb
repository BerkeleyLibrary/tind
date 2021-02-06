require 'typesafe_enum'
module UCBLIT
  module TIND
    module API
      class Format < TypesafeEnum::Base
        new(:ID, 'id')
        new(:XML, 'xml')
        new(:FILES, 'files')

        def to_s
          value
        end

        def to_str
          value
        end
      end
    end
  end
end
