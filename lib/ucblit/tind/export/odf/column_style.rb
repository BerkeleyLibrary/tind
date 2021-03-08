module UCBLIT
  module TIND
    module Export
      module ODF
        class ColumnStyle
          attr_reader :name, :width

          STYLE_COL_DEFAULT = 'co1'.freeze
          WIDTH_DEFAULT = '1in'.freeze

          def initialize(name:, width:)
            @name = name
            @width = width
          end

          def to_s
            "name: #{name}, width: #{width}"
          end

          DEFAULT = ColumnStyle.new(name: STYLE_COL_DEFAULT, width: WIDTH_DEFAULT)
        end
      end
    end
  end
end
