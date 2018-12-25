class AuthorEngine
  class TouchJoystick
    def initialize(x:, y: nil, radius:, side:, background: nil, color: nil)
      @x, @y, @radius, @side, @background, @color = x, y, radius, side, background, color

      @buttons    = AuthorEngine::Part::OpalInput::BUTTONS
      @key_states = AuthorEngine::Part::OpalInput::KEY_STATES

      @game       = AuthorEngine::GameRunner.instance.game
      @game_width = 128 * @game.scale
      @game_x     = `window.innerWidth/2 - #{@game_width/2}`

      if @side == :left
        @x = @game_x-@x
      elsif @side == :right
        @x = @game_x+@game_width+@x
      else
        raise "side must be :left or :right"
      end

      @y = `window.innerHeight/2` unless @y.is_a?(Numeric)
      @color = @game.dark_gray unless @color
      @background = @game.light_gray unless @background

      @joystick_x, @joystick_y, @joystick_radius = @x, @y, @radius/2
    end

    def draw
      # Background
      `#{@game.canvas_context}.fillStyle = #{@background}`
      `#{@game.canvas_context}.beginPath()`
      `#{@game.canvas_context}.arc(#{@x}, #{@y}, #{@radius}, 0, 2 * Math.PI)`
      `#{@game.canvas_context}.fill()`

      # Joystick
      `#{@game.canvas_context}.beginPath()`
      `#{@game.canvas_context}.fillStyle = #{@color}`
      `#{@game.canvas_context}.arc(#{@joystick_x}, #{@joystick_y}, #{@joystick_radius}, 0, 2 * Math.PI)`
      `#{@game.canvas_context}.fill()`

      return nil
    end

    def circles_collide?(x,y, radius, x2,y2, radius2)
      dx = x2 - x
      dy = y2 - y
      radii = radius + radius2

      puts "colliding? #{Math.sqrt(dx * dx + dy * dy) < radii}", Math.sqrt(dx * dx + dy * dy), radii

      if Math.sqrt(dx * dx + dy * dy) < radii
        return true
      else
        return false
      end
    end

    def update(touches)
      touch_detected = false

      touches.detect do |id, touch|
        if circles_collide?(@x, @y, @radius, touch.origin_x, touch.origin_y, 1)
          touch_detected = true

          @joystick_x = touch.x
          @joystick_y = touch.y

          if @joystick_x > @x + @radius
            @joystick_x = @x + @radius
          elsif @joystick_x < @x - @radius
            @joystick_x = @x - @radius
          else
          end

          if @joystick_y > @y + @radius
            @joystick_y = @y + @radius
          elsif @joystick_y < @y - @radius
            @joystick_y = @y - @radius
          else
          end

          return true
        end
      end


      unless touch_detected
        @joystick_x = @x
        @joystick_y = @y
      end

      return nil
    end
  end
end