class AuthorEngine
  class LevelEditor < View
    def setup
      @sprites_picker = SpritePicker.new
      @sprites_picker.y = window.height - @sprites_picker.height
    end

    def focus
      window.caption = "Level Editor"
    end
  end
end