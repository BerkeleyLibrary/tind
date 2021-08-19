require 'berkeley_library/tind/export/config'

module BerkeleyLibrary
  module TIND
    module Export
      # Calculates approximate column widths for cell values, based on
      # Arial average character widths ()in units of 1/1000 point size) per
      # {https://www.math.utah.edu/~beebe/fonts/afm-widths.html this table}.
      # (LibreOffice default is Liberation Sans, which should match Arial.)
      #
      # CJK and fullwidth characters will probably be mapped to another font,
      # but it's probably going to be roughly square.
      #
      # Non-Western, non-CJK characters will *hopefully* not be much wider
      # than their Western counterparts.
      module ColumnWidthCalculator
        include Config

        WIDTH_UNIT = 1000.0

        WIDTH_LOWER = 489.46

        WIDTH_UPPER = 677.42

        WIDTH_DIGIT = 556.0

        # Measured empirically in LibreOffice 6.4.7.2
        WIDTH_CJK = 970.0

        WIDTHS = {
          /[\u4e00-\u9fff]/ => WIDTH_CJK, # CJK (excluding half-width forms)
          /[\uff01-\uff65\uffe0-\uffee]/ => WIDTH_CJK, # Fullwidth forms
          /[[:digit:]]/ => WIDTH_DIGIT,
          /[[:upper:]]/ => WIDTH_UPPER,
          /[[:lower:]]/ => WIDTH_LOWER,
          /[[:space:]]/ => 2 * WIDTH_LOWER / 3 # empirical
        }.freeze

        # See {WIDTHS}
        WIDTH_DEFAULT = WIDTH_DIGIT # Fallback to digit width for other characters

        def width_ps_units(str)
          return 0 if str.nil? || str.empty?

          chars = str.unicode_normalize.chars
          chars.inject(0) { |total, c| total + width_for_char(c) }
        end

        def width_points(str, font_size_points = font_size_pt)
          width_per_point(str) * font_size_points
        end

        def width_inches(str, font_size_points = font_size_pt)
          return 0 if str.nil? || str.empty?

          width_points(str, font_size_points) / 72.0
        end

        private

        def width_per_point(str)
          width_ps_units(str) / WIDTH_UNIT
        end

        def width_for_char(c)
          WIDTHS.each { |re, w| return w if c =~ re }
          WIDTH_DEFAULT
        end

        class << self
          include ColumnWidthCalculator
        end
      end
    end
  end
end
