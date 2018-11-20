class AuthorEngine
  class Palette
    include Support
    include AuthorEngine::Part::Colors

    attr_accessor :x, :y, :width, :height
    def initialize(x:, y:, size: 8)
      @x_padding = window.scale_x
      @y_padding = window.scale_y

      @size = (size * @y_padding)
      @slot_width = 8

      set_origin(x, y)

      @color_set = [
        [
          black,
          dark_blue,
          dark_purple,
          dark_green
        ],
        [
          brown,
          dark_gray,
          light_gray,
          white
        ],
        [
          red,
          orange,
          yellow,
          green
        ],
        [
          blue,
          indigo,
          pink,
          peach
        ]
      ]
      @active_set = 0
      @active_color = nil
    end

    def color
      @active_color
    end

    def set_origin(x, y)
      _x = x
      _y = y

      if x == :center
        _x = window.width/2 - (@slot_width*@size)/2
      end
      if y == :bottom
        _y = window.height - ((@size*2)+@y_padding)
      end

      @x, @y = _x, _y
      @width  = 4 * @size
      @height = 4 * @size
    end

    def draw
      Gosu.draw_rect(@x-window.square_scale, @y-window.square_scale, @width + (window.square_scale*2), @height + (window.square_scale*2), light_gray)
      draw_colors
      hightlight_active_color
    end

    def update
    end

    def button_up(id)
      if id == Gosu::MsLeft
        @color_set.each_with_index do |row, i|
          row.each_with_index do |color, x|
            if window.mouse_x.between?(@x+(x*@size), @x+(x*@size) + @size)
              if window.mouse_y.between?(@y + (@size*i), @y + (@size*i) + @size)
                @active_color = color
              end
            end
          end
        end
      end
    end

    def draw_colors
      @color_set.each_with_index do |row, i|
        row.each_with_index do |color, x|
          z = color == @active_color ? 100 : 7
          Gosu.draw_rect(
            @x+(x*@size), @y+(@size*i),
            @size, @size,
            color,
            z
          )
        end
      end
    end

    def hightlight_active_color
      @color_set.each_with_index do |row, i|
        row.each_with_index do |color, x|
          if color == @active_color
            Gosu.draw_rect(@x+(x*@size)-@x_padding, (@y+(@size*i))-@y_padding, @size+(@x_padding*2), @size+(@y_padding*2), Gosu::Color.rgba(255,255,255, 200), 8)
            break
          end
        end
      end
    end
  end
end