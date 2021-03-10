require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/style/style'
require 'ucblit/util/ods/xml/style/row_style'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          class AutomaticStyles < XML::ElementNode
            # ------------------------------------------------------------
            # Initializer

            def initialize(doc:)
              super(:office, 'automatic-styles', doc: doc)
            end

            # ------------------------------------------------------------
            # Accessor

            def default_style(family)
              first_style = styles_for_family(family).first
              return first_style if first_style

              add_default_style(family)
            end

            # ------------------------------------------------------------
            # Utility methods

            # rubocop:disable Style/OptionalBooleanParameter
            def add_cell_style(name = nil, protected = false, color = nil)
              name ||= next_name_for(:table_cell)
              add_style(Style::CellStyle.new(name, protected, color, doc: doc))
            end
            # rubocop:enable Style/OptionalBooleanParameter

            def add_column_style(name = nil, width = nil)
              name ||= next_name_for(:table_column)
              add_style(Style::ColumnStyle.new(name, width, doc: doc))
            end

            def add_row_style(name = nil, height = nil)
              name ||= next_name_for(:table_row)
              add_style(Style::RowStyle.new(name, height, doc: doc))
            end

            def add_table_style(name = nil)
              name ||= next_name_for(:table)
              add_style(Style::TableStyle.new(name, doc: doc))
            end

            def add_style(style)
              raise ArgumentError, "Not a style: #{style.inspect}" unless style.is_a?(Style::Style)

              style.tap do |s|
                styles_for_family(s.family).tap do |styles|
                  insert_index = styles.find_index { |s1| s1.name > s.name }
                  styles.insert(insert_index || -1, s)
                end
              end
            end

            # ------------------------------------------------------------
            # XML::ElementNode overrides

            def add_child(child)
              return add_style(style) if child.is_a?(Style::Style)

              child.tap { |c| non_style_children << c }
            end

            protected

            def children
              [].tap do |cc|
                Style::Family.each { |f| cc.concat(styles_for_family(f)) }
                cc.concat(non_style_children)
              end
            end

            def create_element
              ensure_default_styles!

              super
            end

            # ------------------------------------------------------------
            # Private methods

            private

            def ensure_default_styles!
              Style::Family.each { |f| default_style(f) }
            end

            def add_default_style(family)
              f = Style::Family.ensure_family(family)
              return add_cell_style if f == Style::Family::TABLE_CELL
              return add_column_style if f == Style::Family::TABLE_COLUMN
              return add_row_style if f == Style::Family::TABLE_ROW
              return add_table_style if f == Style::Family::Table
            end

            def next_name_for(family)
              styles = styles_for_family(f)
              family.next_name(styles.map(&:name))
            end

            def styles_for_family(family)
              (styles_by_family[Family.ensure_family(family)] ||= [])
            end

            def non_style_children
              @addl_children ||= []
            end

            def styles_by_family
              @styles_by_family ||= {}
            end

          end
        end
      end
    end
  end
end
