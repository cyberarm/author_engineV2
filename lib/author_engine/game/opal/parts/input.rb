class AuthorEngine
  class Part
    module Input
      BUTTONS = {
        "left" => Gosu::KbLeft,
        "right" => Gosu::KbRight,
        "up" => Gosu::KbUp,
        "down" => Gosu::KbDown,
        "x" => Gosu::KbX,
        "y" => Gosu::KbC,
      }
      def button?(name)
        down = false

        if BUTTONS.dig(name)
          down = Gosu.button_down?(BUTTONS.dig(name))
        else
          raise "Button '#{name}' not found!"
        end

        return down
      end
    end
  end
end