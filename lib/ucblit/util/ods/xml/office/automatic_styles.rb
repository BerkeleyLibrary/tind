require 'ucblit/util/ods/xml/element_node'
require 'ucblit/util/ods/xml/style/cell_style'
require 'ucblit/util/ods/xml/style/column_style'
require 'ucblit/util/ods/xml/style/row_style'
require 'ucblit/util/ods/xml/style/style'
require 'ucblit/util/ods/xml/style/table_style'

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
            # Accessors

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
              add_style(Style::CellStyle.new(name, protected, color, styles: self))
            end
            # rubocop:enable Style/OptionalBooleanParameter

            def add_column_style(name = nil, width = nil)
              name ||= next_name_for(:table_column)
              add_style(Style::ColumnStyle.new(name, width, styles: self))
            end

            def add_row_style(name = nil, height = nil)
              add_style(Style::RowStyle.new(name || next_name_for(:table_row), height, styles: self))
            end

            def add_table_style(name = nil)
              name ||= next_name_for(:table)
              add_style(Style::TableStyle.new(name, styles: self))
            end

            def add_style(style)
              raise ArgumentError, "Not a style: #{style.inspect}" unless style.is_a?(Style::Style)

              style.tap { |s| add_or_insert_style(s) }
            end

            # rubocop:disable Style/OptionalBooleanParameter
            def find_cell_style(protected = false, color = nil)
              styles_for_family(:table_cell).find { |s| s.protected? == protected && s.color == color }
            end
            # rubocop:enable Style/OptionalBooleanParameter

            def find_column_style(width = nil)
              w = width || Style::ColumnStyle::DEFAULT_WIDTH
              styles_for_family(:table_column).find { |s| s.width == w }
            end

            def find_row_style(height = nil)
              h = height || Style::RowStyle::DEFAULT_HEIGHT
              styles_for_family(:table_row).find { |s| s.height == h }
            end

            # rubocop:disable Style/OptionalBooleanParameter
            def find_or_create_cell_style(protected = false, color = nil)
              existing_style = find_cell_style(protected, color)
              return existing_style if existing_style

              add_cell_style(nil, protected, color)
            end
            # rubocop:enable Style/OptionalBooleanParameter

            def find_or_create_column_style(width = nil)
              existing_style = find_column_style(width)
              return existing_style if existing_style

              add_column_style(nil, width)
            end

            def find_or_create_row_style(height = nil)
              existing_style = find_row_style(height)
              return existing_style if existing_style

              add_row_style(nil, height)
            end

            # ------------------------------------------------------------
            # Public XML::ElementNode overrides

            def add_child(child)
              return add_style(style) if child.is_a?(Style::Style)

              child.tap { |c| other_children << c }
            end

            # ------------------------------------------------------------
            # Protected methods

            protected

            # ----------------------------------------
            # Protected XML::ElementNode overrides

            def children
              [other_children, Style::Family.map { |f| styles_for_family(f) }].flatten
            end

            def create_element
              ensure_default_styles!

              super
            end

            # ------------------------------------------------------------
            # Private methods

            private

            def add_or_insert_style(s)
              styles = styles_for_family(s.family)
              insert_index = styles.find_index do |s1|
                raise ArgumentError, "A #{s.family} style named #{s.name} already exists" if s1.name == s.name

                s1.name > s.name
              end
              insert_index ? styles.insert(insert_index, s) : styles << s
            end

            def ensure_default_styles!
              Style::Family.each { |f| default_style(f) }
            end

            def add_default_style(family)
              f = Style::Family.ensure_family(family)
              return add_cell_style if f == Style::Family::TABLE_CELL
              return add_column_style if f == Style::Family::TABLE_COLUMN
              return add_row_style if f == Style::Family::TABLE_ROW
              return add_table_style if f == Style::Family::TABLE
            end

            def next_name_for(family)
              f = Style::Family.ensure_family(family)
              styles = styles_for_family(f)
              f.next_name(styles.map(&:name))
            end

            def styles_for_family(family)
              (styles_by_family[Style::Family.ensure_family(family)] ||= [])
            end

            def styles_by_family
              @styles_by_family ||= {}
            end

            def other_children
              @other_children ||= []
            end

          end
        end
      end
    end
  end
end
