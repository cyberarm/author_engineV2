class AuthorEngine
  class LevelPicker
    include Support

    def initialize(x: nil, y: nil, z: 10)
      @x, @y, @z = x, y, z

      @offset = 1 * window.square_scale
      @width = window.width - @offset * 4
      @height = (window.tile_size * window.square_scale) + @offset * 2

      @x = window.width / 2 - self.width / 2
    end

    def draw
      Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color::BLACK)
    end

    def update
    end

    def button_up(id)
    end
  end
end