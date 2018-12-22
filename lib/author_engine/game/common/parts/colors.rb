class AuthorEngine
  class Part
    module Colors
      Color = Struct.new(:red, :green, :blue)
      COLORS = {
        0 => Color.new(0,0,0),
        1 => Color.new(29, 43, 83),
        2 => Color.new(126, 37, 83),
        3 => Color.new(0, 135, 81),

        4 => Color.new(171, 82, 54),
        5 => Color.new(95, 87, 79),
        6 => Color.new(194, 195, 199),
        7 => Color.new(255, 241, 232),

        8  => Color.new(255, 0, 77),
        9  => Color.new(255, 163, 0),
        10 => Color.new(225, 236, 39),
        11 => Color.new(0, 228, 54),

        12 => Color.new(41, 173, 255),
        13 => Color.new(131, 118, 156),
        14 => Color.new(225, 119, 168),
        15 => Color.new(255, 204, 170)
      }

      def black;       rgb(COLORS.dig(0)); end
      def dark_blue;   rgb(COLORS.dig(1)); end
      def dark_purple; rgb(COLORS.dig(2)); end
      def dark_green;  rgb(COLORS.dig(3)); end

      def brown;       rgb(COLORS.dig(4)); end
      def dark_gray;   rgb(COLORS.dig(5)); end
      def light_gray;  rgb(COLORS.dig(6)); end
      def white;       rgb(COLORS.dig(7)); end

      def red;         rgb(COLORS.dig(8)); end
      def orange;      rgb(COLORS.dig(9)); end
      def yellow;      rgb(COLORS.dig(10)); end
      def green;       rgb(COLORS.dig(11)); end

      def blue;        rgb(COLORS.dig(12)); end
      def indigo;      rgb(COLORS.dig(13)); end
      def pink;        rgb(COLORS.dig(14)); end
      def peach;       rgb(COLORS.dig(15)); end

      def rgb(color)
        if RUBY_ENGINE == "opal"
          return "rgb(#{color.red}, #{color.green}, #{color.blue})"
        else
          return Gosu::Color.rgb(color.red, color.green, color.blue)
        end
      end

      def xml_color(color)
        red   = color.red.to_s(16)
        green = color.green.to_s(16)
        blue  = color.blue.to_s(16)

        red   = "0#{red}"   if color.red < 10
        green = "0#{green}" if color.green < 10
        blue  = "0#{blue}"  if color.blue < 10

        return "#{red}#{green}#{blue}"
      end
    end
  end
end