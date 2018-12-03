class AuthorEngine
  class Part
    module Colors
      COLORS = {
        0 => Gosu::Color.rgb(0,0,0),
        1 => Gosu::Color.rgb(29, 43, 83),
        2 => Gosu::Color.rgb(126, 37, 83),
        3 => Gosu::Color.rgb(0, 135, 81),

        4 => Gosu::Color.rgb(171, 82, 54),
        5 => Gosu::Color.rgb(95, 87, 79),
        6 => Gosu::Color.rgb(194, 195, 199),
        7 => Gosu::Color.rgb(255, 241, 232),

        8  => Gosu::Color.rgb(255, 0, 77),
        9  => Gosu::Color.rgb(255, 163, 0),
        10 => Gosu::Color.rgb(225, 236, 39),
        11 => Gosu::Color.rgb(0, 228, 54),

        12 => Gosu::Color.rgb(41, 173, 255),
        13 => Gosu::Color.rgb(131, 118, 156),
        14 => Gosu::Color.rgb(225, 119, 168),
        15 => Gosu::Color.rgb(255, 204, 170)
      }

      def black;       COLORS.dig(0); end
      def dark_blue;   COLORS.dig(1); end
      def dark_purple; COLORS.dig(2); end
      def dark_green;  COLORS.dig(3); end

      def brown;       COLORS.dig(4); end
      def dark_gray;   COLORS.dig(5); end
      def light_gray;  COLORS.dig(6); end
      def white;       COLORS.dig(7); end

      def red;         COLORS.dig(8); end
      def orange;      COLORS.dig(9); end
      def yellow;      COLORS.dig(10); end
      def green;       COLORS.dig(11); end

      def blue;        COLORS.dig(12); end
      def indigo;      COLORS.dig(13); end
      def pink;        COLORS.dig(14); end
      def peach;       COLORS.dig(15); end

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