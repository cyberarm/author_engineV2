class AuthorEngine
  class LevelPicker
    include Support

    attr_reader :x, :y, :z, :width, :height, :offset
    attr_reader :active_level, :active_layer
    def initialize(x: nil, y: nil, z: 15)
      @x, @y, @z = x, y, z

      @offset = 1 * window.square_scale
      @width = window.width - @offset * 4
      @height = (window.sprite_size * window.square_scale) + @offset * 2

      @x = window.width / 2 - self.width / 2

      @current_level = AuthorEngine::Text.new(y: @y + @offset*2, z: @z + 1)

      @active_level = 0
      @active_layer = 0

      @max_layers = 16

      @buttons = []

      @buttons << Button.new(label: "-", color: Gosu::Color::GRAY,  x: (window.width / 2) - @offset*8, y: @y + @offset*2, z: 18, tooltip: "↓ Decrease Layer") do
        @active_layer-=1 unless @active_layer < 1
      end
      @buttons << Button.new(label: "+", color: Gosu::Color::GRAY, x: (@buttons.last.x + @buttons.last.width) + @offset*2, y: @y + @offset*2, z: 18, tooltip: "↑ Increase Layer") do
        @active_layer+=1 if @active_layer < @max_layers
      end

      @buttons << Button.new(label: "<", x: (@x + @width) - @width/3, y: @y + @offset*2, z: 18, tooltip: "← Previous Level", color: Gosu::Color::GRAY) do
        @active_level-=1
        @active_level = LevelEditor.instance.levels.size - 1 if @active_level < 0
      end

      @buttons << Button.new(label: "-", x: @buttons.last.x + @buttons.last.width + @offset, y: @y + @offset*2, z: 18, tooltip: "Destroy Level (Non-recoverable)", color: Gosu::Color::RED) do
        if LevelEditor.instance.levels[@active_level].is_a?(Array)
          LevelEditor.instance.levels.delete_at(@active_level)
          @active_level-=1
        end

        if LevelEditor.instance.levels.size == 0
          LevelEditor.instance.levels.push([])
          @active_level = LevelEditor.instance.levels.size - 1
        end
      end

      @buttons << Button.new(label: "+", x: @buttons.last.x + @buttons.last.width + @offset, y: @y + @offset*2, z: 18, tooltip: "Add Level", color: Gosu::Color::GREEN) do
        LevelEditor.instance.levels.push([])
        @active_level = LevelEditor.instance.levels.size - 1
      end


      @buttons << Button.new(label: ">", x: @buttons.last.x + @buttons.last.width + @offset, y: @y + @offset*2, z: 18, tooltip: "→ Next Level", color: Gosu::Color::GRAY) do
        @active_level+=1
        @active_level = 0 if @active_level >= LevelEditor.instance.levels.size - 1
      end
    end

    def draw
      Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color.rgba(255,255,255,220), @z)
      Gosu.draw_rect(@x+4, @y+4, @width-8, @height-8, Gosu::Color.rgba(10, 10, 10,200), @z)

      @buttons.each(&:draw)

      @current_level.message = "Level: #{@active_level}\nLayer: #{@active_layer}/#{@max_layers}"
      @current_level.x = @x + @offset*2
      @current_level.draw
    end

    def button_up(id)
      @buttons.each {|b| b.button_up(id) }

      case id
      when Gosu::KbUp
        @active_layer+=1 if @active_layer < @max_layers

      when Gosu::KbDown
        @active_layer-=1 unless @active_layer < 1

      when Gosu::KbLeft
        @active_level -= 1
        @active_level = LevelEditor.instance.levels.size - 1 if @active_level < 0

      when Gosu::KbRight
        @active_level += 1
        @active_level = 0 unless @active_level < LevelEditor.instance.levels.size
      end
    end
  end
end