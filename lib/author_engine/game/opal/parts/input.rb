class AuthorEngine
  class Part
    module OpalInput
      BUTTONS = {
        "left"  => "ArrowLeft",
        "right" => "ArrowRight",
        "up"    => "ArrowUp",
        "down"  => "ArrowDown",
        "x"     => "x",
        "y"     => "c",
      }

      # Store key states
      KEY_STATES = {
      }

      def button?(name)
        down = false

        if BUTTONS.dig(name)
          down = KEY_STATES.dig(BUTTONS.dig(name)) # dig returns false if key not found
        else
          raise "Button '#{name}' not found!"
        end

        return down
      end
    end
  end
end