class AuthorEngine
  class TouchButton
    attr_reader :x, :y, :width, :height
    def initialize(label:, color:, x:, y: nil, width:, height:, side:, for_key:)
      @label, @color, @x, @y, @width, @height = label, color, x, y, width, height
      @side, @for_key = side, for_key

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

      @y = `window.innerHeight/2 - #{height/2}` unless @y.is_a?(Numeric)
    end

    def draw
      `#{@game.canvas_context}.fillStyle = #{@color}`
      `#{@game.canvas_context}.fillRect(#{@x}, #{@y}, #{width}, #{width})`

      font = "#{@height}px Connection, Consolas"
      `#{@game.canvas_context}.font = #{font}`
      `#{@game.canvas_context}.fillStyle = "white"`
      `#{@game.canvas_context}.textBaseline = "top"`
      `#{@game.canvas_context}.fillText(#{@for_key.upcase}, #{@x}, #{@y}, #{width})`
    end

    def trigger?(touches)
      triggered = false

      touches.detect do |id, touch|
        if touch.x.between?(@x, @x+@width) && touch.y.between?(@y, @y+@height)
          triggered = true
        end
      end


      active if triggered
      inactive unless triggered
    end

    def active
      @key_states[@buttons[@for_key]] = true
    end

    def inactive
      @key_states[@buttons[@for_key]] = false
    end
  end
end