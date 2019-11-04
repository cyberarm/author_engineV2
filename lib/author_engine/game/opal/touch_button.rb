class AuthorEngine
  class TouchButton
    attr_accessor :x, :y
    attr_reader :width, :height
    def initialize(label:, color:, x: 0, y: 0, width:, height:, for_key: nil, &block)
      @label, @color, @x, @y, @width, @height = label, color, x, y, width, height
      @for_key = for_key
      @block = block

      @buttons    = AuthorEngine::Part::OpalInput::BUTTONS
      @key_states = AuthorEngine::Part::OpalInput::KEY_STATES

      @game       = AuthorEngine::GameRunner.instance.game
      @game_width = 128 * @game.authorengine_scale
      @game_x     = `window.innerWidth/2 - #{@game_width/2}`
    end

    def draw
      `#{@game.authorengine_canvas_context}.fillStyle = #{@color}`
      `#{@game.authorengine_canvas_context}.fillRect(#{@x}, #{@y}, #{@width}, #{@height})`

      font = "#{@height}px Connection, Consolas"
      `#{@game.authorengine_canvas_context}.font = #{font}`
      `#{@game.authorengine_canvas_context}.fillStyle = "white"`
      `#{@game.authorengine_canvas_context}.textBaseline = "top"`
      `#{@game.authorengine_canvas_context}.fillText(#{@label}, #{@x}, #{@y}, #{@width})`
    end

    def trigger?(touches)
      triggered = false

      touches.detect do |id, touch|
        if touch.x.between?(@x, @x+@width) && touch.y.between?(@y, @y+@height)
          triggered = true
        end
      end


      if @for_key
        active if triggered
        inactive unless triggered
      else
        @block.call if @block && triggered
      end

      return triggered
    end

    def active
      @key_states[@buttons[@for_key]] = true
    end

    def inactive
      @key_states[@buttons[@for_key]] = false
    end
  end
end