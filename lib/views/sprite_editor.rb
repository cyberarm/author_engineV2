class AuthorEngine
  class SpriteEditor < View
    BLANK_COLOR = Gosu::Color.rgba(0,0,0, 0)
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
      @palette = Palette.new(x: @grid_x + @grid_width + @grid_pixel_size, y: @grid_y)
      @sprites = SpritePicker.new(y: @grid_y + @grid_height + (@grid_pixel_size * 2))

      @pixel_lock = false
      @lock_toggle_button = Button.new(image: "assets/ui/lock_icon.png", tooltip: "Toggle pixel lock", x: @palette.x, y: @palette.y + @palette.height + (window.square_scale * 2), color: dark_purple) do |b|
        @lock_icon ||= b.image
        @unlock_icon ||= Gosu::Image.new("assets/ui/unlock_icon.png", retro: true)

        @pixel_lock = !@pixel_lock

        if @pixel_lock
          b.image = @unlock_icon
        else
          b.image = @lock_icon
        end
      end
    end

    def focus
      window.show_cursor = true
      window.caption = "Sprite Editor"
    end

    def draw
      super
      @pixels.each(&:draw)
      highlight_pixel

      Gosu.draw_rect(@grid_x-window.square_scale, @grid_y-window.square_scale, @grid_width+(window.square_scale*2), @grid_height+(window.square_scale*2), Gosu::Color::WHITE)
      Gosu.draw_rect(@grid_x, @grid_y, @grid_width, @grid_height, Gosu::Color.rgba(10, 10, 10, 200))
      @palette.draw
      @sprites.draw

      @lock_toggle_button.draw
    end

    def update
      super
      paint if Gosu.button_down?(Gosu::MsLeft)
      erase if Gosu.button_down?(Gosu::MsRight)
      @palette.update
    end

    def create_grid(x, y, size)
      size = size * window.scale_y

      @grid_x = (window.width / 2) - (((size * x) / 2) + size*2 )
      @grid_y = window.container.header_height + size
      @grid_width = x * size
      @grid_height = y * size
      @grid_pixel_size = size

      y.times do |_y|
        x.times do |_x|
          @pixels << Pixel.new(
            @grid_x+(_x*size), @grid_y+(_y*size),
            size, size,
            BLANK_COLOR
          )
        end
      end
    end

    def highlight_pixel
      return unless @palette.color

      @pixels.detect do |pixel|
        if window.mouse_x.between?(pixel.x, pixel.x+pixel.width)
          if window.mouse_y.between?(pixel.y, pixel.y+pixel.height)
            Gosu.draw_rect(
              pixel.x, pixel.y,
              pixel.width, pixel.height,
              @palette.color,
              6
            )

            Gosu.draw_rect(
              pixel.x, pixel.y,
              pixel.width, pixel.height,
              Gosu::Color.rgba(255,255,255, 100),
              6
            )
            return true
          end
        end
      end
    end

    def paint(color = @palette.color)
      @pixels.each do |pixel|
        if window.mouse_x.between?(pixel.x, pixel.x+pixel.width)
          if window.mouse_y.between?(pixel.y, pixel.y+pixel.height)
            return if color.nil?
            return if pixel.color != BLANK_COLOR && @pixel_lock
            pixel.color = color
            break
          end
        end
      end
    end

    def erase
      paint(BLANK_COLOR)
    end

    def button_up(id)
      super
      @palette.button_up(id)
      @lock_toggle_button.button_up(id)
      paint if id == Gosu::MsLeft
      erase if id == Gosu::MsRight
    end
  end
end