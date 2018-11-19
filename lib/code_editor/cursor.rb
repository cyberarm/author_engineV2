class AuthorEngine
  class CodeEditor < View
    class Cursor
      include AuthorEngine::Support
      include AuthorEngine::Part::Colors

      attr_reader :active_line, :line_x
      def initialize(view:, text_input:, text:)
        @view = view
        @text_input = text_input
        @text = text

        @last_blink = Gosu.milliseconds
        @blink_interval = 250
        @show = false

        @caret_newline_positions = {}
      end

      def draw
        Gosu.draw_rect(@text.x + @caret_x, @text.y + (@active_line * @text.height), 1, @text.height, light_gray) if @show
      end

      def update
        if (Gosu.milliseconds - @last_blink) > @blink_interval
          @last_blink = Gosu.milliseconds
          @show = !@show
        end

        update_caret
        make_visible
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

        if @caret_x + window.square_scale > @view.width - @text.x
          @view.x_offset = (@view.width - @text.x) - (@caret_x + window.square_scale)
        else
          @view.x_offset = 0
        end
      end

      def make_visible
        @view.y_offset = @view.height - ((@text.y - (window.container.header_height - (@text.height*2))) + (@active_line * @text.height))
        @view.y_offset = 0 if @view.y_offset > 0
      end

      def position
        @text_input.caret_pos
      end

      def set_position(int)
        @text_input.caret_pos = int
        @text_input.selection_start = int # See: https://github.com/gosu/gosu/issues/228
      end

      def move(direction)
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

        set_position(pos)
      end
    end
  end
end