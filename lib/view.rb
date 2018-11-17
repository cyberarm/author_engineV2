class AuthorEngine
  class View
    include Support

    def initialize(x:, y:, width:, height:, background: Gosu::Color::BLACK)
      @x, @y, @width, @height, @background = x, y, width, height, background
    end

    def draw
      Gosu.draw_rect(@x, @y, @width, @height, @background)
    end

    def update
    end

    def button_up(id)
    end
  end
end