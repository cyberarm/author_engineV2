class AuthorEngine
  class TouchJoystick
    def initialize(x:, y: nil, width:, side:)
      @x, @y, @width, @side = x, y, width, side

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

      @y = `window.innerHeight/2 - #{height}` unless @y.is_a?(Numeric)
    end

    def draw
    end

    def update
    end
  end
end