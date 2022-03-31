require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module TindField
        class << self

          def f_035_from_alma_id(alma_id, value_980)
            val = "(#{value_980})#{alma_id}"
            f('035', 'a', val)
          end

          def f_035(val)
            f('035', 'a', val)
          end

          def f_245_p(val)
            f('245', 'p', val)
          end

          def f_fft(url, txt = None)
            return f('FFT', 'a', url) unless txt

            ::MARC::DataField.new('FFT', ' ', ' ', ['d', txt], ['a', url])
          end

          def f_902_d
            f('902', 'd', Time.now.strftime('%F'))
          end

          def f_902_n(name_initial)
            f('902', 'n', name_initial)
          end

          def f_982_p(val)
            f('982', 'p', val)
          end

          def f(tag, code, value)
            ::MARC::DataField.new(tag, ' ', ' ', [code, value])
          end

        end
      end
    end

  end
end
