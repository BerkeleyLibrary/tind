require 'berkeley_library/util/ods/xml/element_node'
require 'berkeley_library/util/ods/xml/table/named_expressions'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Office
          class Spreadsheet < XML::ElementNode
            def initialize(doc:)
              super(:office, 'spreadsheet', doc: doc)
            end

            def named_expressions
              @named_expressions ||= Table::NamedExpressions.new(doc: doc)
            end

            def add_child(child)
              other_children << child
            end

            def children
              other_children.dup.tap { |cc| cc << named_expressions }
            end

            private

            def other_children
              @other_children ||= []
            end

          end
        end
      end
    end
  end
end
