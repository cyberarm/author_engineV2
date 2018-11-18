class AuthorEngine
  class Palette
    include Support

    def initialize(x:, y:, size: 8)
      @x_padding = window.scale_x
      @y_padding = window.scale_y

      @size = (size * @y_padding)
      @slot_width = 8

      set_origin(x, y)

      @color_set = [
        [
          Gosu::Color.rgb(0,0,0),
          Gosu::Color.rgb(29, 43, 83),
          Gosu::Color.rgb(126, 37, 83),
          Gosu::Color.rgb(0, 135, 81)
        ],
        [
          Gosu::Color.rgb(171, 82, 54),
          Gosu::Color.rgb(95, 87, 79),
          Gosu::Color.rgb(194, 195, 199),
          Gosu::Color.rgb(255, 241, 232)
        ],
        [
          Gosu::Color.rgb(255, 0, 77),
          Gosu::Color.rgb(255, 163, 0),
          Gosu::Color.rgb(225, 236, 39),
          Gosu::Color.rgb(0, 228, 54)
        ],
        [
          Gosu::Color.rgb(41, 173, 255),
          Gosu::Color.rgb(131, 118, 156),
          Gosu::Color.rgb(225, 119, 168),
          Gosu::Color.rgb(255, 204, 170)
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
    end

    def draw
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
            # Gosu.draw_rect(@x+(x*@size), @y, @size, @size, Gosu::Color.rgba(255,255,255, 100))
            break
          end
        end
      end
    end
  end
end