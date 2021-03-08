module UCBLIT
  module TIND
    module Export
      module ODF
        # Arial average character widths in units of 1/1000 point size, per
        # {https://www.math.utah.edu/~beebe/fonts/afm-widths.html this table}.
        #
        # CJK and fullwidth characters will probably be mapped to another font,
        # but it's probably going to be roughly square.
        #
        # Non-Western, non-CJK characters will *hopefully* not be much wider
        # than their Western counterparts.
        module Width

          class << self
            WIDTH_UNIT = 1000.0

            WIDTH_LOWER = 489.46

            WIDTH_UPPER = 677.42

            WIDTH_DIGIT = 556.0

            WIDTHS = {
              /[\u4e00-\u9fff]/ => WIDTH_UNIT, # CJK (excluding half-width forms)
              /[\uff01-\uff65\uffe0-\uffee]/ => WIDTH_UNIT, # Fullwidth forms
              /[[:digit:]]/ => WIDTH_DIGIT,
              /[[:upper:]]/ => WIDTH_UPPER,
              /[[:lower:]]/ => WIDTH_LOWER,
              /[[:space:]]/ => 2 * WIDTH_LOWER / 3 # empirical
            }.freeze

            # See {WIDTHS}
            WIDTH_DEFAULT = WIDTH_LOWER # Fallback to lowercase width for other characters

            FONT_SIZE_DEFAULT = 10.0

            def width_ps_units(str)
              return 0 if str.nil? || str.empty?

              chars = str.unicode_normalize.chars
              chars.inject(0) { |total, c| total + width_for_char(c) }
            end

            def width_points(str, font_size_points = FONT_SIZE_DEFAULT)
              width_per_point(str) * font_size_points
            end

            def width_inches(str, font_size_points = FONT_SIZE_DEFAULT)
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
          end
        end
      end
    end
  end
end
