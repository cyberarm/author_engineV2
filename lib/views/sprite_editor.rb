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
      @sprites= []
      @active_color = Gosu::Color.rgba(101,1,101, 255)

      create_grid(16, 16, 4)
      @canvas_changed = false
      @palette = Palette.new(x: @grid_x + @grid_width + @grid_pixel_size, y: @grid_y)
      @sprites_picker = SpritePicker.new(y: @grid_y + @grid_height + (@grid_pixel_size * 2))

      @tools = []
      @pixel_lock = false
      @pixel_floodfill = false # aka bucket tool

      @tools << Button.new(image: "assets/ui/lock_icon.png", tooltip: "Toggle pixel lock", x: @palette.x, y: @palette.y + @palette.height + (window.square_scale * 2), color: dark_purple) do |b|
        @lock_icon ||= b.image
        @unlock_icon ||= AuthorEngine::Image.new("assets/ui/unlock_icon.png", retro: true)

        @pixel_lock = !@pixel_lock

        if @pixel_lock
          b.image = @unlock_icon
        else
          b.image = @lock_icon
        end
      end

      @tools << Button.new(image: "assets/ui/lock_icon.png", tooltip: "Toggle bucket", x: @palette.x + @tools.first.width, y: @palette.y + @palette.height + (window.square_scale * 2), color: dark_purple) do |b|
        @lock_icon ||= b.image
        @unlock_icon ||= AuthorEngine::Image.new("assets/ui/unlock_icon.png", retro: true)

        @pixel_floodfill = !@pixel_floodfill

        if @pixel_floodfill
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
      @sprites_picker.draw

      @tools.each(&:draw)
    end

    def update
      super
      unless @pixel_floodfill
        paint if Gosu.button_down?(Gosu::MsLeft)
        erase if Gosu.button_down?(Gosu::MsRight)
      end
      @palette.update
    end

    def create_grid(x, y, size)
      size = size * window.square_scale

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

    def get_pixel_at(x, y)
      @pixels.detect do |pixel|
        if x.between?(pixel.x, pixel.x+pixel.width)
          if y.between?(pixel.y, pixel.y+pixel.height)
            return pixel
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
            @canvas_changed = true
            pixel.color = color
            break
          end
        end
      end
    end

    def erase
      paint(BLANK_COLOR)
    end

    # AKA The Bucket Tool
    # @param pixel [Pixel]
    # @param target_color [Gosu::Color] color to search and replace with replacement_color
    # @param replacement_color [Gosu::Color] color to replace Pixel's current color
    def floodfill(pixel, target_color, replacement_color)
      return unless pixel
      return if pixel.color == replacement_color
      return if pixel.color != target_color

      pixel.color = replacement_color
      @canvas_changed = true

      # UP
      _pixel = get_pixel_at(pixel.x, pixel.y)
      floodfill(_pixel, target_color, replacement_color)

      # DOWN
      # _pixel = get_pixel_at(pixel.x, pixel.y + @grid_pixel_size)
      # floodfill(_pixel, target_color, replacement_color)

      # LEFT
      # _pixel = get_pixel_at(pixel.x - @grid_pixel_size, pixel.y)
      # floodfill(_pixel, target_color, replacement_color)

      # RIGHT
      # _pixel = get_pixel_at(pixel.x + @grid_pixel_size, pixel.y)
      # floodfill(_pixel, target_color, replacement_color)
    end

    def sprites
      @sprites
    end

    def update_sprite
      list = []

      @pixels.each_slice(window.sprite_size).each do |row|
        list << row
      end

      image = Gosu.render(window.sprite_size, window.sprite_size, retro: true) do
        list.each_with_index do |row, y|
          row.each_with_index do |pixel, x|
            Gosu.draw_rect(x, y, 1, 1, pixel.color)
          end
        end
      end

      if @sprites[@sprites_picker.active_sprite]
        @sprites[@sprites_picker.active_sprite] = nil # release image for garbage collection?
        @sprites[@sprites_picker.active_sprite] = image
      else
        @sprites.insert(@sprites_picker.active_sprite, image)
      end
      @canvas_changed = false
    end

    def build_sprite_sheet
    end

    def button_up(id)
      super
      @palette.button_up(id)
      @sprites_picker.button_up(id)

      @tools.each{ |b| b.button_up(id) }

      if @pixel_floodfill && @palette.color
        pixel = get_pixel_at(window.mouse_x, window.mouse_y)
        if pixel
          floodfill(pixel, pixel.color, @palette.color) if id == Gosu::MsLeft
          floodfill(pixel, pixel.color, BLANK_COLOR) if id == Gosu::MsRight
        end
      end

      update_sprite if id == (Gosu::MsLeft || Gosu::MsRight) && @canvas_changed
    end
  end
end