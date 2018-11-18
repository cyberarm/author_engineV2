class AuthorEngine
  class PlayViewer < View
    def setup
      @running = false
    end

    def run(code: nil)
      # Do something with code from CodeEditor
      # in order to play the game.
      @running = true
      window.container.lock
    end

    def focus
      if Gosu.milliseconds > 100
        @running = true
        window.container.lock
      end
    end

    def draw
      # super
      if @running
        draw_game
      end
    end

    def update
      # super
      if @running
        update_game
      end
    end

    def draw_game
      Gosu.draw_rect(
        0,
        0,
        128 * window.square_scale,
        128 * window.square_scale,
        Gosu::Color::BLACK,
        7
      )
    end

    def update_game
    end

    def stop
      @running = false
      window.container.unlock
    end

    def button_up(id)
      stop if id == Gosu::KbEscape
    end
  end
end