class AuthorEngine
  class LevelPicker
    include Support

    attr_reader :x, :y, :z, :width, :height, :offset
    attr_reader :active_level
    def initialize(x: nil, y: nil, z: 15)
      @x, @y, @z = x, y, z

      @offset = 1 * window.square_scale
      @width = window.width - @offset * 4
      @height = (window.sprite_size * window.square_scale) + @offset * 2

      @x = window.width / 2 - self.width / 2

      @current_level = AuthorEngine::Text.new(y: @y + @offset*2, z: @z + 1)

      @active_level = 0

      @delete_level = Button.new(label: "-", x: (@x + @width) - @width/4, y: @y + @offset*2, z: 18, tooltip: "Remove Level", color: Gosu::Color::RED) do
        if LevelEditor.instance.levels[@active_level].is_a?(Array)
          LevelEditor.instance.levels.delete_at(@active_level)
          @active_level-=1
        end

        if LevelEditor.instance.levels.size == 0
          LevelEditor.instance.levels.push([])
          @active_level = LevelEditor.instance.levels.size - 1
        end
      end

      @add_level = Button.new(label: "+", x: @delete_level.x + @delete_level.width + @offset, y: @y + @offset*2, z: 18, tooltip: "Add Level", color: Gosu::Color::GREEN) do
        LevelEditor.instance.levels.push([])
        @active_level = LevelEditor.instance.levels.size - 1
      end
    end

    def draw
      Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color.rgba(255,255,255,220), @z)
      Gosu.draw_rect(@x+4, @y+4, @width-8, @height-8, Gosu::Color.rgba(10, 10, 10,200), @z)

      @delete_level.draw
      @add_level.draw

      @current_level.message = "Level: #{@active_level}"
      @current_level.x = @x + (@current_level.width/2)
      @current_level.draw
    end

    def button_up(id)
      @delete_level.button_up(id)
      @add_level.button_up(id)

      case id
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