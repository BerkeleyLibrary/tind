require 'berkeley_library/util/ods/xml/element_node'
require 'berkeley_library/util/ods/xml/style/style'
require 'berkeley_library/util/ods/xml/style/default_style'
require 'berkeley_library/util/ods/xml/style/paragraph_properties'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Office
          class Styles < XML::ElementNode
            def initialize(doc:)
              super(:office, 'styles', doc: doc)

              add_default_children!
            end

            private

            def add_default_children!
              add_child(table_cell_default_style)
              add_child(Style::Style.new('Default', 'table-cell', doc: doc))
            end

            def table_cell_default_style
              style_children = [
                Style::ParagraphProperties.new(doc: doc),
                Style::TextProperties.new(font_name: Style::FontFace::DEFAULT_FONT_FACE, doc: doc)
              ]
              Style::DefaultStyle.new('table-cell', doc: doc).tap do |ds|
                style_children.each { |c| ds.add_child(c) }
              end
            end
          end
        end
      end
    end
  end
end
