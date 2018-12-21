class AuthorEngine
  class LevelEditor < View
    Sprite = Struct.new(:sprite, :x, :y, :z)

    attr_reader :levels
    def setup
      @sprites_picker = SpritePicker.new(y: 0)
      @sprites_picker.y = window.height - (@sprites_picker.height+(@sprites_picker.offset*2))

      @level_picker = LevelPicker.new(y: self.y + 4)

      @show_sprite_picker = true
      @show_level_picker  = true
      @levels = [ [] ]

      @viewport_x, @viewport_y = 0, 0

      @scale = (self.height.to_f / AuthorEngine::Window::VIEW_HEIGHT)
      @editor_x, @editor_y = self.width / 2 - ((AuthorEngine::Window::VIEW_HEIGHT * @scale) / 2), self.y

      @sprite_size =  window.sprite_size
    end

    def focus
      window.caption = "Level Editor"
    end

    def draw
      super
      @sprites_picker.draw if @show_sprite_picker
      @level_picker.draw if @show_level_picker


      Gosu.draw_rect(@editor_x - 4, @editor_y, (128 * @scale) + 8, (128 * @scale), white)
      Gosu.clip_to(@editor_x, @editor_y, 128 * @scale,128 * @scale) do
        Gosu.draw_rect(@editor_x, @editor_y, 128 * @scale,128 * @scale, Gosu::Color::BLACK)

        Gosu.translate(@viewport_x, @viewport_y) do
          Gosu.scale(@scale, @scale, @editor_x, @editor_y) do
            if @levels[@level_picker.active_level]
              @levels[@level_picker.active_level].each do |s|
                SpriteEditor.instance.sprites[s.sprite].draw(
                  ((s.x) * @sprite_size) + @editor_x,
                  ((s.y) * @sprite_size) + @editor_y,
                  s.z
                )
              end
            end

            SpriteEditor.instance.sprites[@sprites_picker.active_sprite].draw(
              (normalize((window.mouse_x - @viewport_x) - @editor_x) * @sprite_size) + @editor_x,
              (normalize((window.mouse_y - @viewport_y) - @editor_y) * @sprite_size) + @editor_y,
              0, 1,1,
              Gosu::Color.rgba(255,255,255, 150)
            )
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
        if window.mouse_x.between?(@sprites_picker.x, @sprites_picker.x + @sprites_picker.width) &&
          window.mouse_y.between?(window.height - (@sprites_picker.offset*2+4), window.height)
          @show_sprite_picker = true
        end
      end

      if mouse_over?(@level_picker) && @show_level_picker
        @show_level_picker = true
      else
        @show_level_picker = false
        if window.mouse_x.between?(@level_picker.x, @level_picker.x + @level_picker.width) &&
          window.mouse_y.between?(self.y, self.y + (@level_picker.offset*2+4))
          @show_level_picker = true
        end
      end

      if mouse_inside_view?
        if (!@show_sprite_picker && !@show_level_picker)
          move_viewport
        end
      end

      # puts "X: #{normalize(window.mouse_x - @editor_x)} y: #{normalize(window.mouse_y - @editor_y)}"
    end

    def place_or_remove_tile(button)
      return unless mouse_inside_view?

      case button
      when Gosu::MsLeft
        place(normalize((window.mouse_x - @viewport_x) - @editor_x), normalize((window.mouse_y - @viewport_y) - @editor_y), @level_picker.active_layer, :add)
      when Gosu::MsRight
        place(normalize((window.mouse_x - @viewport_x) - @editor_x), normalize((window.mouse_y - @viewport_y) - @editor_y), @level_picker.active_layer, :remove)
      end
    end

    def move_viewport
      if window.button_down?(Gosu::KbUp)
        @viewport_y += 1 * @scale
      elsif window.button_down?(Gosu::KbDown)
        @viewport_y -= 1 * @scale
      elsif window.button_down?(Gosu::KbLeft)
        @viewport_x += 1 * @scale
      elsif window.button_down?(Gosu::KbRight)
        @viewport_x -= 1 * @scale
      elsif window.button_down?(Gosu::Kb0)
        @viewport_x, @viewport_y = 0, 0
      end
    end

    def normalize(int)
      i = (int.to_f / (@sprite_size * @scale)).floor
      if i < 0
        i = 0
      end

      return i
    end

    def place(x, y, z, mode)
      sprite = @levels[@level_picker.active_level].detect do |s|
        s.x == x && s.y == y && s.z == z
      end

      case mode
      when :add
        new_sprite = Sprite.new(@sprites_picker.active_sprite, x, y, z)
        if sprite
          @levels[@level_picker.active_level][@levels[@level_picker.active_level].index(sprite)] = new_sprite
        else
          @levels[@level_picker.active_level] << new_sprite
        end
      when :remove
        @levels[@level_picker.active_level].delete(sprite) if sprite
      else
        raise
      end
    end

    def button_up(id)
      super
      @sprites_picker.button_up(id) if @show_sprite_picker
      @level_picker.button_up(id)   if @show_level_picker

      if (!@show_sprite_picker && !@show_level_picker)
        place_or_remove_tile(id)
      end
    end
  end
end