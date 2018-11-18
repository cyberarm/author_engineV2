class AuthorEngine
  class CodeEditor < View
    class CodeInput < Gosu::TextInput
      def filter(text_in)
        return text_in
      end
    end

    VARAIBLE = Gosu::Color::GREEN
    DEFINIION = 800

    DEFAULT_STRING = <<-EOF
def init
end

def draw
end

def update
end
    EOF


    def setup
      @text_input = CodeInput.new
      @text_input.text = DEFAULT_STRING
      @text = AuthorEngine::Text.new(message: "", x: 9 * window.scale_y, y: window.container.header_height)

      @font  = Gosu::Font.new((8 * window.scale_y).floor, name: "Consolas")
    end

    def focus
      window.text_input = @text_input
    end

    def draw
      super
      @text.draw_markup
      draw_caret

      Gosu.draw_rect(0, window.container.header_height, 8 * window.scale_y, window.height - window.container.header_height, Gosu::Color::GRAY)

      (@text.message.lines.map(&:chomp)).each_with_index do |line, index|
        @font.draw_text("#{index+1}", 1, window.container.header_height + (@font.height * index), 0)
      end
    end

    def update
      super
      @text.message = @text_input.text if @text_input
      highlight_text
    end

    def draw_caret
      active_line = 0

      i = 1
      string = ""
      line_position = 0
      @text_input.text.each_char do |char|
        if char == "\n"
          active_line+=1
          string = ""
          line_position = 0
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
      substring = (@text_input.text.lines.map(&:chomp))[active_line]
      if substring
        substring2= substring.sub(string,  "")
        substring3= substring.sub(substring2, "")

        x = @font.text_width(substring3)
      else
        x = @font.text_width((@text_input.text.lines.map(&:chomp))[active_line])
      end

      Gosu.draw_rect(@text.x + x, @text.y + (active_line * @text.height), 1, @text.height, Gosu::Color::BLACK)
    end

    def highlight_text
      @text.message.gsub!("def ", "<c=#{DEFINIION}>def </c>")
      @text.message.gsub!("end\n", "<c=#{DEFINIION}>end</c>\n")
    end

    def button_up(id)
      if id == Gosu::KbEnter || id == Gosu::KbReturn
        @text_input.text = @text_input.text+"\n"
      end
    end
  end
end