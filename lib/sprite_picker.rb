class AuthorEngine
  class SpritePicker
    include Support

    def initialize(x:, y:, width:, height:)
      @x, @y, @width, @height = x, y, width, height

      p (@width / 16.0)
      p (@height / 16.0)
    end

    def draw
      Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color::BLACK, 15)
      draw_grid
      draw_sprites
    end

    def draw_grid
      deviser = @width / (16 * window.square_scale).floor
      (deviser).floor.times do |i|
        i += 1
        # Vertical line
        Gosu.draw_rect((@x + (i * (@width / deviser))) - 1, @y, 1, @height, Gosu::Color::WHITE, 16)
      end
      #Horizontal line
      Gosu.draw_rect(@x, @y + (@height / 2), @width, 1, Gosu::Color::WHITE, 16)
    end

    def draw_sprites
    end

    def update
    end

    def button_up(id)
    end
  end
end