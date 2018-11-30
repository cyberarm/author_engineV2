class AuthorEngine
  class Text
    include Support
    FONT_DEFAULT = "assets/fonts/Connection.otf"
    FONT_DEFAULT_BOLD = "assets/fonts/ConnectionBold.otf"

    attr_accessor :message, :x, :y, :z, :color
    attr_reader :size, :font
    def initialize(message: "", size: nil, x: 0, y: 0, z: 0, color: Gosu::Color::WHITE, font: FONT_DEFAULT) # Consolas
      @message = message
      @size = size ? size : (8 * window.scale_y).floor
      @x, @y, @z = x, y, z
      @color, @font_name = color, font

      @font = Gosu::Font.new(@size, name: @font_name)
    end

    def width
      @font.text_width(@message)
    end

    def width_markup
      @font.markup_width(@message)
    end

    def height
      @font.height
    end

    def draw
      @font.draw_text(@message, @x, @y, @z, 1, 1, @color)
    end

    def draw_markup
      @font.draw_markup(@message, @x, @y, @z, 1, 1, @color)
    end

    def update
    end
  end
end