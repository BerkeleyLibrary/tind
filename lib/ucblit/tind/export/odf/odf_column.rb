require 'rodf'

module UCBLIT
  module TIND
    module Export
      module ODF
        class ODFColumn < RODF::Column

          attr_reader :elem_attrs

          def initialize(opts = {})
            super

            elem_attrs['table:default-cell-style-name'] = opts[:default_cell_style_name] if opts[:default_cell_style_name]
          end

        end
      end
    end
  end
end
