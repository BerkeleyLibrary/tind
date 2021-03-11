require 'ucblit/util/ods/xml/namespace'
require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/table/table'
require 'ucblit/util/ods/xml/office/scripts'
require 'ucblit/util/ods/xml/office/font_face_decls'
require 'ucblit/util/ods/xml/office/automatic_styles'
require 'ucblit/util/ods/xml/office/body'
require 'ucblit/util/ods/xml/office/spreadsheet'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class DocumentContent < XML::ElementNode

            # ------------------------------------------------------------
            # Initializer

            def initialize(doc:)
              super(:office, 'document-content', doc: doc)

              set_default_attributes!
              add_default_children!
            end

            # ------------------------------------------------------------
            # Accessors and utility methods

            def scripts
              @scripts ||= Scripts.new(doc: doc)
            end

            def font_face_decls
              @font_face_decls ||= Office::FontFaceDecls.new(doc: doc)
            end

            def automatic_styles
              @automatic_styles ||= Office::AutomaticStyles.new(doc: doc)
            end

            def add_table(name, table_style = nil, protected: true)
              new_table = XML::Table::Table.new(name, table_style, styles: automatic_styles, protected: protected)
              new_table.tap { |table| spreadsheet.children << table }
            end

            def spreadsheet
              @spreadsheet ||= Office::Spreadsheet.new(doc: doc)
            end

            def body
              @body ||= Body.new(doc: doc).tap { |body| body.children << spreadsheet }
            end

            # ------------------------------------------------------------
            # Private methods

            private

            def set_default_attributes!
              Namespace.each { |ns| set_attribute(:xmlns, ns.prefix, ns.uri) }
              set_attribute('version', '1.2')
            end

            def add_default_children!
              children << scripts
              children << font_face_decls
              children << automatic_styles
              children << body
            end
          end
        end
      end
    end
  end
end
