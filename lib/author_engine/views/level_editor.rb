class AuthorEngine
  class LevelEditor < View
    Sprite = Struct.new(:sprite, :x, :y)

    def setup
      @sprites_picker = SpritePicker.new(y: 0)
      @sprites_picker.y = window.height - (@sprites_picker.height+(@sprites_picker.offset*2))

      @show_sprite_picker = true
      @sprites = []

      @viewport_x, @viewport_y = 0, 0
    end

    def focus
      window.caption = "Level Editor"
    end

    def draw
      super
      @sprites_picker.draw if @show_sprite_picker

      Gosu.translate(@viewport_x, @viewport_y) do
        Gosu.clip_to(self.x, self.y, self.width, self.height) do
          Gosu.scale(window.square_scale) do
            @sprites.each {|s| SpriteEditor.instance.sprites[s.sprite].draw(s.x, s.y, 0)}

            SpriteEditor.instance.sprites[@sprites_picker.active_sprite].draw(normalize(window.mouse_x), normalize(window.mouse_y), 0, 1,1, Gosu::Color.rgba(255,255,255, 150))
          end
        end
      end
    end

    def update
      super

      if mouse_over?(@sprites_picker) && @show_sprite_picker
        @show_sprite_picker = true
      else
        @show_sprite_picker = false
        @show_sprite_picker = true if window.mouse_x.between?(@sprites_picker.x, @sprites_picker.x + @sprites_picker.width) && window.mouse_y.between?(window.height - (@sprites_picker.offset*2+4), window.height)
      end
    end

    def place_or_remove_tile(button)
      case button
      when Gosu::MsLeft
        place(normalize(window.mouse_x), normalize(window.mouse_y), :add)
      when Gosu::MsRight
        place(normalize(window.mouse_x), normalize(window.mouse_y), :remove)
      end
    end

    def normalize(int)
      return (int.to_f / window.sprite_size).floor * window.sprite_size
    end

    def place(x, y, mode)
      sprite = @sprites.detect do |s|
        s.x == x && s.y == y
      end

      case mode
      when :add
        new_sprite = Sprite.new(@sprites_picker.active_sprite, x, y)
        if sprite
          @sprites[@sprites.index(sprite)] = new_sprite
        else
          @sprites << new_sprite
        end
      when :remove
        @sprites.delete(sprite) if sprite
      else
        raise
      end
    end

    def button_up(id)
      super
      @sprites_picker.button_up(id) if @show_sprite_picker
      place_or_remove_tile(id) unless @show_sprite_picker
    end
  end
end