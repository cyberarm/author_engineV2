class AuthorEngine
  class Text
    attr_accessor :message, :x, :y, :z, :color
    attr_reader :size, :font
    def initialize(message: "", size: 8, x: 0, y: 0, z: 0, color: Gosu::Color::WHITE, font: "Consolas") # Gosu.default_font_name
      @message = message
      @size = size
      @x, @y, @z = x, y, z
      @color, @font_name = color, font

      @font = Gosu::Font.new(size, name: @font_name)
    end

    def width
      @font.text_width(@message)
    end

    def height
      @font.height
    end

    def draw
      @font.draw_text(@message, @x, @y, @z, 1, 1, @color)
    end

    def update
    end
  end
end