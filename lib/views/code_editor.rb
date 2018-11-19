class AuthorEngine
  class CodeEditor < View

    class CodeInput < Gosu::TextInput
      def filter(text_in)
        return text_in
      end
    end

    DEFAULT_STRING = <<-EOF
def init
  @size = 10
  @x    = 59
  @y    = 59
end

def draw
  rect(@x, @y, @size, @size, pink)
  text("x: \#{@x}, y: \#{@y}", 0, 0, 8)
end

def update
  @x+=1 if button?("right")
  @x-=1 if button?("left")
  @y-=1 if button?("up")
  @y+=1 if button?("down")

  @x = 0            if @x < 0
  @x = 128-@size if @x > 128-@size

  @y = 0            if @y < 0
  @y = 128-@size if @y > 128-@size
end
    EOF


    def setup
      @highlight_colors = {
        instance_variable: xml_color(green),
        keyword: xml_color(red),
        method: xml_color(yellow),
        ident: xml_color(yellow),
        comment: xml_color(dark_gray),
        constant: xml_color(orange),

        delimiter: xml_color(blue),
        content: xml_color(blue),
        integer: xml_color(blue),
        float: xml_color(blue),
        symbol: xml_color(blue),
      }

      @font_size = 6 * window.square_scale.floor
      @font = Gosu::Font.new(@font_size, name: Text::FONT_DEFAULT_BOLD) # "Consolas"
      @line_numbers_spacing = "00"
      @line_numbers_width   = @font.text_width(@line_numbers_spacing)

      @text_input = CodeInput.new
      @text_input.text = DEFAULT_STRING
      @text = AuthorEngine::Text.new(message: "", size: @font_size, x: @line_numbers_width+@x_padding, y: window.container.header_height, font: Text::FONT_DEFAULT) # "DejaVu Sans Mono"

      @last_text = ""

      @cursor_last_blink = Gosu.milliseconds
      @cursor_blink_interval = 250
      @show_cursor = false
      @active_line = 0
      @caret_x = 0
      @caret_newline_positions = {}
      @caret_pos = @text_input.caret_pos


      @highlight_color = Gosu::Color.rgba(dark_gray.red, dark_gray.green, dark_gray.blue, 100)

      @x_offset, @y_offset = 0, 0
    end

    def focus
      window.text_input = @text_input
      window.caption = "Code Editor"
      @active_line = 0
    end

    def blur
      window.text_input = nil
    end

    def draw
      super
      Gosu.clip_to(0, window.container.header_height, window.width, window.height - window.container.header_height) do
        Gosu.translate(0, @y_offset) do
          Gosu.draw_rect(0, window.container.header_height, @line_numbers_width, Float::INFINITY, dark_gray)

          min_width = @font.text_width("0")+@x_padding
          (@text.message.lines.map(&:chomp)).each_with_index do |line, index|
            min_width = @font.text_width("#{index+1}") if @font.text_width("#{index+1}") > min_width

            @font.draw_text("#{index+1}", 1, window.container.header_height + (@font.height * index), 0)
          end

          @line_numbers_width = min_width
          @text.x = @line_numbers_width+@x_padding
        end

        Gosu.translate(@x_offset, @y_offset) do
          Gosu.clip_to(@line_numbers_width, window.container.header_height, window.width, Float::INFINITY) do
            highlight_line
            @text.draw_markup
            draw_caret if @show_cursor
          end
        end
      end
    end

    def update
      super
      # @text_input.text+="\n" if Gosu.button_down?(Gosu::KbEnter) || Gosu.button_down?(Gosu::KbReturn) # FIXME
      @caret_pos = @text_input.caret_pos
      update_caret
      highlight_text

      if (Gosu.milliseconds - @cursor_last_blink) > @cursor_blink_interval
        @cursor_last_blink = Gosu.milliseconds
        @show_cursor = !@show_cursor
      end

      make_cursor_visible
    end

    def make_cursor_visible
      @y_offset = @height - ((@text.y - (window.container.header_height - @text.height)) + (@active_line * @text.height))
      @y_offset = 0 if @y_offset > 0
    end

    def code; @text_input.text; end

    def draw_caret
      Gosu.draw_rect(@text.x + @caret_x, @text.y + (@active_line * @text.height), 1, @text.height, light_gray)
    end

    def update_caret
      @active_line = 0
      @caret_x = 0

      i = 1
      newline_count = 0
      virt_caret = 0
      string = ""
      line_position = 0
      @text_input.text.each_char do |char|
        virt_caret += 1
        if char == "\n"
          @caret_newline_positions[newline_count] = virt_caret-1 # go behind newline
          newline_count+=1

          @active_line+=1
          string = ""
          line_position = 0
        elsif @active_line == 0 && @text_input.caret_pos == 0
          break
        else
          string+=char
          line_position+=1
        end

        unless i < @text_input.caret_pos
          break
        end
        i+=1
      end

      substring = (@text_input.text.lines.map(&:chomp))[@active_line]
      if substring
        substring2= substring.sub(string,  "")
        substring3= substring.sub(substring2, "")

        @caret_x = @text.font.markup_width(substring3)
      else
        @caret_x = @text.font.markup_width((@text_input.text.lines.map(&:chomp))[@active_line])
      end

      if @caret_x + window.square_scale > @width - @text.x
        @x_offset = (@width - @text.x) - (@caret_x + window.square_scale)
      else
        @x_offset = 0
      end
    end

    def highlight_text
      return unless @last_text != @text_input.text
      @last_text = @text_input.text

      text = ""

      tokens = CodeRay.scan(@text_input.text, :ruby).tokens
      tokens.each_with_index do |token, index|
        text = "#{text}#{style(token, tokens[index+1])}" if token.is_a?(String)
      end

      @text.message = text
    end

    def style(text, token)
      color = @highlight_colors.dig(token)
      if color
        return "<c=#{color}>#{text}</c>"
      else
        return text
      end
    end

    def highlight_line
      Gosu.draw_rect(0, @text.y + (@active_line * @text.height), Float::INFINITY, @text.height, @highlight_color)
    end

    def move_cursor(direction)
      pos = @text_input.caret_pos

      if direction == :up
        return if @active_line == 0
        pos = @caret_newline_positions[@active_line-1]

      elsif direction == :down
        return if @text_input.caret_pos == @text_input.text.size
        return unless @caret_newline_positions[@active_line+1]
        pos = @caret_newline_positions[@active_line+1]

      else
        raise
      end

      @text_input.caret_pos = pos
      @text_input.selection_start = pos # See: https://github.com/gosu/gosu/issues/228
    end

    def button_up(id)
      if id == Gosu::KbEnter || id == Gosu::KbReturn
        raise if @caret_pos != @text_input.caret_pos
        @text_input.text = @text_input.text.insert(@text_input.caret_pos, "\n")
        @text_input.caret_pos = @text_input.caret_pos+1
      end

      move_cursor(:up) if id == Gosu::KbUp
      move_cursor(:down) if id == Gosu::KbDown
    end
  end
end