module UCBLIT
  module TIND
    module Export
      module Config

        # Font size in points
        FONT_SIZE_DEFAULT = 10.0

        # Round column widths up to nearest eighth inch
        WIDTH_INCREMENT_DEFAULT_INCHES = '1/8'.to_r

        # Round row heights up to nearest 2 points
        HEIGHT_INCREMENT_DEFAULT_POINTS = 2

        # Max column width before wrapping
        MAX_COLUMN_WIDTH_INCHES = 5.0

        # Decimal places for formatting
        FORMAT_DIGITS_DEFAULT = 3

        # Line height as multiple of font size
        LINE_HEIGHT_DEFAULT_EM = '4/3'.to_r

        # @return [Numeric] the font size in points
        def font_size_pt
          Config.font_size_pt
        end

        # @return [Numeric] the max column width in inches
        def max_col_width_in
          Config.max_col_width_in
        end

        # @return [Numeric] the width rounding increment in inches
        def w_incr_in
          Config.w_incr_in
        end

        # @return [Numeric] the height rounding increment in points
        def h_incr_pt
          Config.h_incr_pt
        end

        # @return [Numeric] the line height in ems (multiples of the font point size)
        def line_height_em
          Config.line_height_em
        end

        # @return [Integer] the number of digits to use when formatting values
        def format_digits
          Config.format_digits
        end

        # noinspection RubyYardReturnMatch
        class << self

          # @return [Numeric] the font size in points
          def font_size_pt
            @font_size_pt ||= ensure_positive_numeric(ENV['ODS_FONT_SIZE_DEFAULT'] || Config::FONT_SIZE_DEFAULT)
          end

          def font_size_pt=(value)
            @font_size_pt = ensure_positive_numeric(value)
          end

          # @return [Numeric] the max column width in inches
          def max_col_width_in
            @max_col_width_in ||= ensure_positive_numeric(ENV['ODS_MAX_COLUMN_WIDTH_INCHES'] || Config::MAX_COLUMN_WIDTH_INCHES)
          end

          def max_col_width_in=(value)
            @max_col_width_in = ensure_positive_numeric(value)
          end

          # @return [Numeric] the width rounding increment in inches
          def w_incr_in
            @w_incr_in ||= ensure_positive_numeric(ENV['ODS_WIDTH_INCREMENT_DEFAULT_INCHES'] || Config::WIDTH_INCREMENT_DEFAULT_INCHES)
          end

          def w_incr_in=(value)
            @w_incr_in = ensure_positive_numeric(value)
          end

          # @return [Numeric] the height rounding increment in points
          def h_incr_pt
            @h_incr_pt ||= ensure_positive_numeric(ENV['ODS_HEIGHT_INCREMENT_DEFAULT_POINTS'] || Config::HEIGHT_INCREMENT_DEFAULT_POINTS)
          end

          def h_incr_pt=(value)
            @h_incr_pt = ensure_positive_numeric(value)
          end

          # @return [Numeric] the line height in ems (multiples of the font point size)
          def line_height_em
            @line_height_em ||= ensure_positive_numeric(ENV['ODS_LINE_HEIGHT_DEFAULT_EM'] || Config::LINE_HEIGHT_DEFAULT_EM)
          end

          def line_height_em=(value)
            @line_height_em = ensure_positive_numeric(value)
          end

          # @return [Integer] the number of digits to use when formatting values
          def format_digits
            @format_digits ||= ensure_positive_int(ENV['ODS_FORMAT_DIGITS_DEFAULT'] || Config::FORMAT_DIGITS_DEFAULT)
          end

          def format_digits=(value)
            @format_digits = ensure_positive_int(value)
          end

          private

          # @param v [Object] a value
          # @return [Numeric] a numeric value, or nil if the value is not numeric
          def ensure_positive_numeric(v)
            v_n = ensure_numeric(v)
            return v_n if v_n > 0

            raise ArgumentError, "Value must be positive: #{v_n}"
          end

          def ensure_numeric(v)
            return v if v.is_a?(Numeric)

            v_str = v.to_s
            return v_str.to_r if v_str.include?('/')
            return v_str.to_f if v_str.include?('.')
            return Integer(v_str) if v_str =~ /(?:0x\h+|\d+)/

            raise ArgumentError, "Can't parse #{v.inspect} as a numeric value"
          end

          # @param v [Object] a value
          # @return [Integer]
          def ensure_positive_int(v)
            v_i = ensure_int(v)
            return v_i if v_i > 0

            raise ArgumentError, "Value must be positive: #{v_i}"
          end

          def ensure_int(v)
            return v if v.is_a?(Integer)

            v_str = v.to_s
            return Integer(v_str) if v_str =~ /(?:0x\h+|\d+)/

            raise ArgumentError, "Can't parse #{v.inspect} as an integer value"
          end
        end
      end
    end
  end
end
