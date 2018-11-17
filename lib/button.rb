class AuthorEngine
  class Button
    include Support

    PADDING = 2

    attr_reader :label, :text, :block, :image, :width, :height, :x, :y
    attr_accessor :z
    def initialize(label: nil, image: nil, x: 0, y: 0, z: 0, color: Gosu::Color::GREEN, &block)
      @label, @image = label, image
      @x, @y, @z = x, y, z
      @color = color
      @block = block

      @width, @height = 0, 0

      if @label.is_a?(String)
        @text = AuthorEngine::Text.new(message: @label, x: @x, y: @y, z: @z)
      end

      if @image.is_a?(String)
        @image = Gosu::Image.new(@image, retro: true)
      end

      set_interactive_colors
      position_elements

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
        @image.draw(@x+PADDING, @y+PADDING, @z)

      else
        raise "Nothing to draw! (text and image were nil or invalid types)"
      end
    end

    def position_elements
      if @text && @text.is_a?(AuthorEngine::Text)
        @text.x, @text.y = @x+PADDING, @y+PADDING
        @width, @height = @text.width+PADDING, @text.height+PADDING

      elsif @image && @image.is_a?(AuthorEngine::Sprite)
        @image.x, @image.y = @x+PADDING, @y+PADDING
        @width, @height = @image.width+PADDING, @image.height+PADDING

      elsif @image && @image.is_a?(Gosu::Image)
        @width, @height = @image.width+PADDING, @image.height+PADDING

      else
        raise "From Button -> text and image were nil or invalid types"
      end
    end

    def call
      @block.call(self) if @block
    end
  end
end