class AuthorEngine
  module Support
    def window
      Window.instance
    end

    def code_editor
      CodeEditor.instance
    end

    def sprite_editor
      SpriteEditor.instance
    end

    def mouse_over?(object)
      if window.mouse_x.between?(object.x, object.x + object.width) &&
        window.mouse_y.between?( object.y, object.y + object.height)
        true
      end
    end
  end
end