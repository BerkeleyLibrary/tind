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

          def protect!
            @protected = true
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
              # # TODO: does this work in OpenOffice or only LibreOffice?
              # xml << Builder::XmlMarkup.new.tag!(
              #   'loext:table-protection',
              #   'loext:select-protected-cells' => 'true',
              #   'loext:select-unprotected-cells' => 'true'
              # )
              xml << columns_xml
              xml << rows_xml
            end
          end

        end
      end
    end
  end
end
