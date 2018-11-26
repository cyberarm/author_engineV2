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
  @x    = width/2  - @size/2
  @y    = height/2 - @size/2
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


    attr_accessor :x_offset, :y_offset
    def setup
      @font_size = 6 * window.square_scale.floor
      @font = Gosu::Font.new(@font_size, name: Text::FONT_DEFAULT_BOLD) # "Consolas"
      @line_numbers_spacing = "00"
      @line_numbers_width   = @font.text_width(@line_numbers_spacing)

      @text_input = CodeInput.new
      if window.container.savefile.code.nil?
        @text_input.text = DEFAULT_STRING
      else
        @text_input.text = window.container.savefile.code
      end
      @text = AuthorEngine::Text.new(message: "", size: @font_size, x: @line_numbers_width+@x_padding, y: window.container.header_height, font: Text::FONT_DEFAULT) # "DejaVu Sans Mono"

      @cursor = Cursor.new(view: self, text_input: @text_input, text: @text)
      @highlighting = Highlighting.new

      @x_offset, @y_offset = 0, 0
    end

    def focus
      window.text_input = @text_input
      window.caption = "Code Editor"
    end

    def blur
      window.text_input = nil
    end

    def draw
      # Gosu.draw_rect(0, window.container.header_height, @width, @height, white)
      super
      Gosu.clip_to(0, window.container.header_height, window.width, window.height - window.container.header_height) do
        Gosu.draw_rect(0, window.container.header_height, @line_numbers_width, @height, dark_gray)

        Gosu.translate(0, @y_offset) do
          min_width = @font.text_width("0")+@x_padding
          (@text.message.lines.map(&:chomp)).each_with_index do |line, index|
            min_width = @font.text_width("#{index+1}") if @font.text_width("#{index+1}") > min_width

            @font.draw_text("#{index+1}", 1, window.container.header_height + (@font.height * index), 0)
          end

          @line_numbers_width = min_width
          @text.x = @line_numbers_width+@x_padding
        end
      end

      Gosu.clip_to(@line_numbers_width, window.container.header_height, window.width, @height) do
        Gosu.translate(@x_offset, @y_offset) do
          @text.draw_markup
          @cursor.draw
        end
      end
    end

    def update
      super
      # @text_input.text+="\n" if Gosu.button_down?(Gosu::KbEnter) || Gosu.button_down?(Gosu::KbReturn) # FIXME
      @caret_pos = @text_input.caret_pos
      @highlighting.highlight(string: @text_input.text, text: @text)

      @cursor.update
    end

    def code; @text_input.text; end

    def button_up(id)
      cursor_pos = @text_input.caret_pos # get a copy of the current cursor location

      if id == Gosu::KbEnter || id == Gosu::KbReturn
        # raise if @caret_pos != @text_input.caret_pos
        @text_input.text = @text_input.text.insert(@text_input.caret_pos, "\n")
        @cursor.set_position(cursor_pos+1)
      end

      @cursor.move(:up) if id == Gosu::KbUp
      @cursor.move(:down) if id == Gosu::KbDown

      if id == Gosu::KbTab
        text = @text_input.text

        if window.shift_button_down?
          # FIXME: remove spaces behide cursor

          # chars = @text_input.text.chars

          # if text[cursor_pos] == " " && text[cursor_pos-1] == " "
          #   chars.delete_at(cursor_pos-1)
          #   chars.delete_at(cursor_pos)
          #   @cursor.set_position(cursor_pos-2)

          #   text = chars.join
          # elsif text[cursor_pos] == " "
          #   chars.delete_at(cursor_pos-1)
          #   @cursor.set_position(cursor_pos-1)

          #   text = chars.join
          # else
          #   p text[cursor_pos]
          # end

        else
          @text_input.text = @text_input.text.insert(cursor_pos, "  ")
          p cursor_pos+2
          @cursor.set_position(cursor_pos+2)
        end
      end

      if id == Gosu::KbA && window.control_button_down?
        @cursor.select_all
      end

      @cursor.button_up(id)
    end
  end
end