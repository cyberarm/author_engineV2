class AuthorEngine
  class Button
    include Support

    PADDING = 2

    attr_reader :label, :text, :block, :image, :width, :height, :x, :y, :tag
    attr_accessor :z
    def initialize(label: nil, tooltip: nil, image: nil, x: 0, y: 0, z: 0, color:, tag: nil, &block)
      @label, @image = label, image
      @x, @y, @z = x, y, z
      @color = color
      @tag   = tag
      @block = block

      @width, @height = 0, 0
      @x_padding = PADDING * window.scale_x
      @y_padding = PADDING * window.scale_y

      if @label.is_a?(String)
        @text = AuthorEngine::Text.new(message: @label, x: @x, y: @y, z: @z)
      end

      if @image.is_a?(String)
        @image = Gosu::Image.new(@image, retro: true)
      end

      set_interactive_colors
      position_elements

      if tooltip.is_a?(String)
        @tooltip = AuthorEngine::Text.new(message: tooltip, x: @x, y: @y+@height, z: 1000)
      end

      return self
    end

    def draw
      if mouse_over? && Gosu.button_down?(Gosu::MsLeft)
        draw_background(@color_active)
      elsif mouse_over?
        draw_background(@color_hover)
      else
        draw_background(@color)
      end
      draw_element

      draw_tooltip if @tooltip && mouse_over?
    end

    def button_up(id)
      call if mouse_over? && (id == Gosu::MsLeft)
    end

    def x=(n)
      @x = n
      position_elements
    end

    def y=(n)
      @y = n
      position_elements
    end

    def label=(s)
      @label = s
      @text.message = s
      position_elements
    end

    def set_interactive_colors
      if @color.value > 0.3
        @color_active = Gosu::Color.new(@color.alpha-50, @color.red, @color.green, @color.blue)
        @color_hover  = Gosu::Color.new(@color.alpha-25, @color.red, @color.green, @color.blue)
      else
        @color_active = Gosu::Color.new(@color.alpha-25, @color.red, @color.green, @color.blue)
        @color_hover  = Gosu::Color.new(@color.alpha-10, @color.red, @color.green, @color.blue)
      end
    end


    def mouse_over?
      if window.mouse_x.between?(@x, @x+@width) &&
        window.mouse_y.between?(@y, @y+@height)
        true
      end
    end

    def draw_background(color)
      Gosu.draw_rect(@x, @y, @width, @height, color, @z)
    end

    def draw_element
      if @text && @text.is_a?(AuthorEngine::Text)
        @text.draw

      elsif @image && @image.is_a?(AuthorEngine::Sprite)
        @image.draw

      elsif @image && @image.is_a?(Gosu::Image)
        @image.draw(@x+@x_padding, @y+@y_padding, @z, (1 * window.square_scale), (1 * window.square_scale))

      else
        raise "Nothing to draw! (text and image were nil or invalid types)"
      end
    end

    def draw_tooltip
      Gosu.draw_rect(@tooltip.x-@x_padding, @tooltip.y-(@y_padding*2), @tooltip.width+(@x_padding*2), @tooltip.height+(@y_padding*2), Gosu::Color.rgba(0,0,0, 200), @tooltip.z)
      @tooltip.draw
    end

    def position_elements
      if @text && @text.is_a?(AuthorEngine::Text)
        @text.x, @text.y = @x+@x_padding, @y+@y_padding
        @width, @height = @text.width+(@x_padding*2), @text.height+(@y_padding*2)

      elsif @image && @image.is_a?(AuthorEngine::Sprite)
        @image.x, @image.y = @x+@x_padding, @y+@y_padding
        @width, @height = @image.width+(@x_padding*2), @image.height+(@y_padding*2)

      elsif @image && @image.is_a?(Gosu::Image)
        @width, @height = (@image.width * window.square_scale)+(@x_padding*2), (@image.height * window.square_scale)+(@y_padding)

      else
        raise "From Button -> text and image were nil or invalid types"
      end

      if @tooltip
        if (@x + @tooltip.width + @x_padding) > window.width
          @tooltip.x = @x - (((@x+@tooltip.width) - window.width) + @x_padding)
        else
          @tooltip.x = (@x - @tooltip.width / 2) + @width/2
        end

        @tooltip.y = (@y + @height + (@y_padding*2))
      end
    end

    def call
      @block.call(self) if @block
    end
  end
end