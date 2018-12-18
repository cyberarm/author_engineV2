class AuthorEngine
  class LevelEditor < View
    def setup
      @sprites_picker = SpritePicker.new(y: 0)
      @sprites_picker.y = window.height - (@sprites_picker.height+(@sprites_picker.offset*2))

      @show_sprite_picker = true
    end

    def focus
      window.caption = "Level Editor"
    end

    def draw
      super
      @sprites_picker.draw if @show_sprite_picker
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
        place(normalize(window.mouse_x), normalize(window.mouse_y))
      when Gosu::MsRight
      end
    end

    def button_up(id)
      super
      @sprites_picker.button_up(id) if @show_sprite_picker
      place_or_remove_tile(id) unless @show_sprite_picker
    end
  end
end