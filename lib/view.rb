class AuthorEngine
  class View
    include Support
    include AuthorEngine::Part::Colors

    def self.instance
      @instance
    end

    def self.instance=(klass)
      @instance = klass
    end

    attr_reader :x, :y, :width, :height, :background
    def initialize(x:, y:, width:, height:, background: Gosu::Color::BLACK)
      @x, @y, @width, @height, @background = x, y, width, height, background

      @x_padding = Button::PADDING * window.scale_x
      @y_padding = Button::PADDING * window.scale_y

      self.class.instance = self
      setup
    end

    def setup
    end

    def focus
    end

    def blur
    end

    def draw
      Gosu.draw_rect(@x, @y, @width, @height, @background)
    end

    def mouse_inside_view?
      if window.mouse_x.between?(@x, @x+@width)
        if window.mouse_y.between?(@y, @y+@height)
          return true
        end
      end
    end

    def update
    end

    def button_up(id)
    end
  end
end