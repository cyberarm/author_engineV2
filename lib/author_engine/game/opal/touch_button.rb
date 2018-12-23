class AuthorEngine
  class TouchButton
    attr_reader :x, :y, :width, :height
    def initialize(label:, color:, x:, y: nil, width:, height:, side:, contact_proc:, no_contact_proc:)
      @label, @color, @x, @y, @width, @height = label, color, x, y, width, height
      @side, @contact_proc, @no_contact_proc = side, contact_proc, no_contact_proc

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
      `#{@game.canvas_context}.fillStyle = #{@color}`
      `#{@game.canvas_context}.fillRect(#{@x}, #{@y}, #{width}, #{width})`
    end

    def active
      @contact_proc.call
    end

    def inactive
      @no_contact_proc.call
    end
  end
end