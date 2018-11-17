class AuthorEngine
  class SpriteEditor < View
    MAGIC_BLANK_COLOR = Gosu::Color.rgba(1,1,1, 222)
    class Pixel
      attr_accessor :x, :y, :width, :height, :color
      def initialize(x, y, width, height, color)
        @x, @y, @width, @height, @color = x, y, width, height, color
      end

      def draw
        Gosu.draw_rect(
          @x, @y,
          @width, @height,
          @color,
          5
        )
      end
    end

    def setup
      @pixels = []
      @active_color = Gosu::Color.rgba(101,1,101, 255)

      create_grid(16, 16, 4)
      @palette = Palette.new(:center, :bottom)
    end

    def focus
      window.show_cursor = true
      window.caption = "Painter"
    end

    def draw
      super
      @pixels.each(&:draw)
      highlight_pixel

      @palette.draw
    end

    def update
      super
      @palette.update
    end

    def create_grid(x, y, size)
      size = size * window.scale_y

      x_offset = window.width/2 - (x*size)/2
      y_offset = window.height/2 - (y*size)/2

      y.times do |_y|
        x.times do |_x|
          @pixels << Pixel.new(
            x_offset+(_x*size), y_offset+(_y*size),
            size, size,
            MAGIC_BLANK_COLOR
          )
        end
      end
    end

    def highlight_pixel
      @pixels.each do |pixel|
        if window.mouse_x.between?(pixel.x, pixel.x+pixel.width)
          if window.mouse_y.between?(pixel.y, pixel.y+pixel.height)
            Gosu.draw_rect(
              pixel.x, pixel.y,
              pixel.width, pixel.height,
              Gosu::Color.rgba(255,255,255, 100),
              6
            )
            break
          end
        end
      end
    end

    def paint(color = @palette.color)
      @pixels.each do |pixel|
        if window.mouse_x.between?(pixel.x, pixel.x+pixel.width)
          if window.mouse_y.between?(pixel.y, pixel.y+pixel.height)
            return if color.nil?
            pixel.color = color
            break
          end
        end
      end
    end

    def erase
      paint(MAGIC_BLANK_COLOR)
    end

    def button_up(id)
      super
      @palette.button_up(id)
      paint if id == Gosu::MsLeft
      erase if id == Gosu::MsRight

      window.close if id == Gosu::KbEscape
    end
  end
end