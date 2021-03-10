module UCBLIT
  module Util
    module ODS
      class Table

        class Column
          attr_reader :name, :protected, :width

          def initialize(name, protected: false, width: nil)
            @name = name
            @protected = protected
            @width = width
          end
        end
      end
    end
  end
end
