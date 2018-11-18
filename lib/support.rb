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
  end
end