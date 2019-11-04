class AuthorEngine
  class TouchJoystick
    attr_accessor :x, :y, :radius
    def initialize(x: 0, y: 0, radius:, background: nil, color: nil)
      @x, @y, @radius, @background, @color = x, y, radius, background, color

      @buttons    = AuthorEngine::Part::OpalInput::BUTTONS
      @key_states = AuthorEngine::Part::OpalInput::KEY_STATES

      @game       = AuthorEngine::GameRunner.instance.game
      @game_width = 128 * @game.authorengine_scale
      @game_x     = `window.innerWidth/2 - #{@game_width/2}`

      @color = @game.dark_gray unless @color
      @background = @game.light_gray unless @background

      @joystick_x, @joystick_y, @joystick_radius = @x, @y, @radius/2
    end

    def draw
      #Clear
      combo = @radius + @joystick_radius
      `#{@game.authorengine_canvas_context}.clearRect(#{@x - combo}, #{@y - combo}, #{combo + combo}, #{combo + combo})`

      # Background
      `#{@game.authorengine_canvas_context}.fillStyle = #{@background}`
      `#{@game.authorengine_canvas_context}.beginPath()`
      `#{@game.authorengine_canvas_context}.arc(#{@x}, #{@y}, #{@radius}, 0, 2 * Math.PI)`
      `#{@game.authorengine_canvas_context}.fill()`

      # Joystick
      `#{@game.authorengine_canvas_context}.beginPath()`
      `#{@game.authorengine_canvas_context}.fillStyle = #{@color}`
      `#{@game.authorengine_canvas_context}.arc(#{@joystick_x}, #{@joystick_y}, #{@joystick_radius}, 0, 2 * Math.PI)`
      `#{@game.authorengine_canvas_context}.fill()`

      return nil
    end

    def circles_collide?(x,y, radius, x2,y2, radius2)
      radii = radius + radius2

      if @game.distance(x,y, x2,y2) < radii
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

          _distance = @game.distance(@x,@y, touch.x,touch.y).clamp(0, @radius)
          _direction = Math.atan2(touch.y - @y, touch.x - @x)

          @joystick_x = @x +(_distance * Math.cos(_direction))
          @joystick_y = @y +(_distance * Math.sin(_direction))

          return true
        end
      end


      unless touch_detected
        @joystick_x = @x
        @joystick_y = @y
      end

      trigger_input

      return nil
    end

    def trigger_input(threshold = 0.35)
      threshold = @radius * threshold

      if @joystick_x != @x || @joystick_y != @y
        if (@x - @joystick_x) < -threshold
          set("right", true)
        else
          set("right", false)
        end

        if (@x - @joystick_x) > threshold
          set("left", true)
        else
          set("left", false)
        end

        if (@y - @joystick_y) < -threshold
          set("down", true)
        else
          set("down", false)
        end

        if (@y - @joystick_y) > threshold
          set("up", true)
        else
          set("up", false)
        end

      else
        set("up", false)
        set("down", false)
        set("left", false)
        set("right", false)
      end
    end

    def set(key, boolean)
      @key_states[@buttons[key]] = boolean
    end
  end
end