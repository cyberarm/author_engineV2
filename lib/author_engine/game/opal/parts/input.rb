class AuthorEngine
  class Part
    module Input
      BUTTONS = {
        "left"  => `ArrowLeft`,
        "right" => `ArrowRight`,
        "up"    => `ArrowUp`,
        "down"  => `ArrowDown`,
        "x"     => `KeyX`,
        "y"     => `ArrowC`,
      }

      # Store keys state
      KEY_STATES = {
      }

      def button?(name)
        down = false

        if BUTTONS.dig(name)
          down = KEY_STATES.dig(name) # dig returns false if key not found
        else
          raise "Button '#{name}' not found!"
        end

        return down
      end
    end
  end
end