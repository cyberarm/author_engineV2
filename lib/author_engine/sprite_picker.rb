class AuthorEngine
  class SpritePicker
    include Support

    attr_reader :active_sprite
    attr_reader :x, :y, :width, :height
    attr_reader :rows, :columns
    def initialize(x: nil, y:, width: nil, height: nil)
      @x, @y, @width, @height = x, y, width, height
      @sprite_size = window.sprite_size
      @scaled_sprite_size = @sprite_size * window.square_scale
      @active_sprite = 0 # array index

      @width = width ? width : window.width - (@scaled_sprite_size)
      @height= height ? height : @scaled_sprite_size*2

      @x = x ? x : window.width/2 - @width/2

      @columns = (@width  / @scaled_sprite_size).floor
      @rows    = (@height / @scaled_sprite_size).floor

      @offset = 1 * window.square_scale
      @tooltip = AuthorEngine::Text.new(message: "", z: 100)
      @current_page = AuthorEngine::Text.new(message: "Page 0", size: 20, x: window.width/2, y: @y - 24, z: 100)

      @page = 0
    end

    def y=(n)
      @y = n
    end

    def draw
      Gosu.draw_rect(@x-@offset, @y-@offset, @width+(@offset*2), @height+(@offset*2), Gosu::Color::WHITE, 15)
      Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color.rgba(10, 10, 10, 200), 15)
      draw_grid
      draw_sprites

      draw_and_update_tooltip
      @current_page.message = "Page #{@page}"
      @current_page.draw
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
      size  = (@columns * @rows)
      index = size * @page

      SpriteEditor.instance.sprites[index..(index + size)].each_with_index do |sprite, i|
        sprite.draw(x, y, 16, 1.0 * window.square_scale, 1.0 * window.square_scale) if sprite
        x+=@scaled_sprite_size

        if n >= @columns-1
          y+=@scaled_sprite_size
          x = @x
          n = 0
        else
          n += 1
        end
      end

      highlight_sprite
    end

    def highlight_sprite
      sprite_block do |x, y|
        Gosu.draw_rect(x + @x, y + @y, @sprite_size * window.square_scale, @sprite_size * window.square_scale, Gosu::Color.rgba(0,0,0, 50), 17)
      end
    end

    def mouse_over_sprite?(x, y, width, height)
      if window.mouse_x.between?(x, x + width) &&
         window.mouse_y.between?(y, y + height)
         return true
      end
    end

    def draw_and_update_tooltip
      found = false

      sprite_block do |x,y,index|
        if @tooltip
          @tooltip.message = "#{index}"
          @tooltip.x = window.mouse_x - @tooltip.width/2
          @tooltip.y = window.mouse_y - @tooltip.height
        end

        found = true
      end

      if found
        Gosu.draw_rect(@tooltip.x - @offset, @tooltip.y - @offset, @tooltip.width+(@offset*2), @tooltip.height+(@offset), Gosu::Color.rgba(0,0,0,100), 100)
        @tooltip.draw
      else
        @tooltip.message = ""
      end
    end

    def select_sprite
      sprite_block do |x, y, index|
        @active_sprite = index
        SpriteEditor.instance.set_sprite
      end
    end

    def sprite_block(&block)
      found = false
      index = @page * (@columns * @rows)

      @rows.times do |y|
        _y = y * @scaled_sprite_size
        break if found

        @columns.times do |x|
          break if found
          _x = x * @scaled_sprite_size

          if mouse_over_sprite?(_x + @x, _y + @y, @sprite_size * window.square_scale, @sprite_size * window.square_scale)
            found = true
            block.call(_x, _y, index, found) if block
          end

          break if index >= 255
          index+=1
        end
      end
    end

    def button_up(id)
      case id
      when Gosu::MsLeft
        if mouse_over?(self)
          select_sprite
        end
      when Gosu::KbLeft
        @page-=1
        @page = (255/(@rows * @columns)) if @page < 0
      when Gosu::KbRight
        @page+=1
        @page = 0 if @page > (255/(@rows * @columns))
      end
    end
  end
end