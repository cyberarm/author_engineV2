class AuthorEngine
  class CodeEditor < View
    include AuthorEngine::Part::Colors

    class CodeInput < Gosu::TextInput
      def filter(text_in)
        return text_in
      end
    end

    DEFAULT_STRING = <<-EOF
def init
  @x = 0
  @y = 0
end

def draw
  rect(@x, @y, 10, 10)
  text("x: \#{@x}, y: \#{@y}", 0, 0, 8)
end

def update
  @x+=1 if button?("right")
  @x-=1 if button?("left")
  @y-=1 if button?("up")
  @y+=1 if button?("down")
end
    EOF


    def setup
      @highlight_colors = {
        instance_variable: xml_color(green),
        keyword: xml_color(red),
        method: xml_color(yellow),
        ident: xml_color(yellow),
        comment: xml_color(dark_gray),
        constant: xml_color(black),

        delimiter: xml_color(blue),
        content: xml_color(blue),

        integer: xml_color(blue),
        float: xml_color(blue),
      }

      @text_input = CodeInput.new
      @text_input.text = DEFAULT_STRING
      @font_size = 6 * window.square_scale.floor
      @text = AuthorEngine::Text.new(message: "", size: @font_size, x: 9 * window.scale_y, y: window.container.header_height, font: "DejaVu Sans Mono")

      @font  = Gosu::Font.new(@font_size, name: "Consolas")
      @cursor_last_blink = Gosu.milliseconds
      @cursor_blink_interval = 250
      @show_cursor = false

      @highlight_color = Gosu::Color.rgba(@background.red-25, @background.green-25, @background.blue-25, 100)

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
          Gosu.draw_rect(0, window.container.header_height, 8 * window.scale_y, Float::INFINITY, black)

          (@text.message.lines.map(&:chomp)).each_with_index do |line, index|
            @font.draw_text("#{index+1}", 1, window.container.header_height + (@font.height * index), 0)
          end
        end

        Gosu.translate(@x_offset, @y_offset) do
          highlight_line
          @text.draw_markup
          draw_caret if @show_cursor
        end
      end
    end

    def update
      super
      @text.message = @text_input.text if @text_input
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
      @active_line = 0

      i = 1
      string = ""
      line_position = 0
      @text_input.text.each_char do |char|
        if char == "\n"
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

      x = 0
      substring = (@text_input.text.lines.map(&:chomp))[@active_line]
      if substring
        substring2= substring.sub(string,  "")
        substring3= substring.sub(substring2, "")

        x = @text.font.markup_width(substring3)
      else
        x = @text.font.markup_width((@text_input.text.lines.map(&:chomp))[@active_line])
      end

      if x + window.square_scale > @width - @text.x
        @x_offset = (@width - @text.x) - (x + window.square_scale)
      else
        @x_offset = 0
      end


      Gosu.draw_rect(@text.x + x, @text.y + (@active_line * @text.height), 1, @text.height, light_gray)
    end

    def highlight_text
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

    def button_up(id)
      if id == Gosu::KbEnter || id == Gosu::KbReturn
        @text_input.text = @text_input.text+"\n"
      end
    end
  end
end