class AuthorEngine
  class Game
    include AuthorEngine::Part::Colors
    include AuthorEngine::Part::Graphics
    include AuthorEngine::Part::Input

    def initialize(code:)
      @background_color = Gosu::Color::BLACK
      self.instance_eval(code)
    end

    def draw_background
      Gosu.draw_rect(0, 0, Window::VIEW_WIDTH, Window::VIEW_HEIGHT, @background_color)
    end

    def init
    end

    def draw
    end

    def update
    end
  end
end