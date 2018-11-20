class AuthorEngine
  class SpritePicker
    include Support

    attr_reader :active_sprite
    def initialize(x: nil, y:, width: nil, height: nil)
      @x, @y, @width, @height = x, y, width, height
      @sprite_size = window.sprite_size
      @scaled_sprite_size = @sprite_size * window.square_scale
      @active_sprite = 0 # array index

      @width = width ? width : window.width - (@scaled_sprite_size)
      @height= height ? height : @scaled_sprite_size*2

      @x = x ? x : window.width/2 - @width/2

      p (@width  / @scaled_sprite_size).floor
      p (@height / @scaled_sprite_size).floor

      @columns = (@width  / @scaled_sprite_size).floor
      @rows    = (@height / @scaled_sprite_size).floor

      @offset = 1 * window.square_scale
    end

    def draw
      # Gosu.clip_to(@x, @y, @width, @height) do
        Gosu.draw_rect(@x-@offset, @y-@offset, @width+(@offset*2), @height+(@offset*2), Gosu::Color::WHITE, 15)
        Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color.rgba(10, 10, 10, 200), 15)
        draw_grid
        draw_sprites
      # end
    end

    def draw_grid
      (@columns-1).times do |i|
        i += 1
        # Vertical line
        Gosu.draw_rect((@x + (i * @width /  @columns)) - 1, @y, 1, @height, Gosu::Color::WHITE, 17)
      end
      #Horizontal line
      (@rows-1).times do |i|
        Gosu.draw_rect(@x, (@y + (i * @height / @rows)) + @scaled_sprite_size, @width, 1, Gosu::Color::WHITE, 17)
      end
    end

    def draw_sprites
      y = @y
      x = @x
      n = 0
      SpriteEditor.instance.sprites.each_with_index do |sprite, i|
        sprite.draw(x, y, 16, 1.0 * window.square_scale, 1.0 * window.square_scale) if sprite
        x+=@scaled_sprite_size

        if n >= @columns-1
          y+=@scaled_sprite_size
          x = @x
          n = 0
        end
        n += 1
      end
    end

    def update
    end

    def button_up(id)
    end
  end
end