require 'rodf'

module UCBLIT
  module TIND
    module Export
      module ODF
        class ODFTable < RODF::Table

          def initialize(title = nil, protected: true)
            super(title)
            @protected = protected
          end

          def protected?
            @protected
          end

          def xml
            return super unless protected?

            Builder::XmlMarkup.new.tag!(
              'table:table',
              'table:name' => @title,
              'table:protected' => 'true'
            ) do |xml|
              xml << columns_xml
              xml << rows_xml
            end
          end

        end
      end
    end
  end
end
