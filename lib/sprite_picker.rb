class AuthorEngine
  class SpritePicker
    include Support

    def initialize(x: nil, y:, width: nil, height: nil)
      @x, @y, @width, @height = x, y, width, height
      @sprite_size = window.sprite_size
      @scaled_sprite_size = @sprite_size * window.square_scale

      @width = width ? width : window.width - (@scaled_sprite_size)
      @height= height ? height : @scaled_sprite_size*2

      @x = x ? x : window.width/2 - @width/2

      p (@width  / @scaled_sprite_size).floor
      p (@height / @scaled_sprite_size).floor

      @columns = (@width  / @scaled_sprite_size).floor
      @rows    = (@height / @scaled_sprite_size).floor
    end

    def draw
      Gosu.clip_to(@x, @y, @width, @height) do
        Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color::BLACK, 15)
        draw_grid
        draw_sprites
      end
    end

    def draw_grid
      (@columns-1).times do |i|
        i += 1
        # Vertical line
        Gosu.draw_rect((@x + (i * @width /  @columns)) - 1, @y, 1, @height, Gosu::Color::WHITE, 16)
      end
      #Horizontal line
      (@rows-1).times do |i|
        Gosu.draw_rect(@x, (@y + (i * @height / @rows)) + @scaled_sprite_size, @width, 1, Gosu::Color::WHITE, 16)
      end
    end

    def draw_sprites
    end

    def update
    end

    def button_up(id)
    end
  end
end