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

        @x, @y = 0, 0

        @last_blink = Gosu.milliseconds
        @last_position = 0
        @blink_interval = 250
        @show = false

        @newline_data = {}
        @active_line  = 0

        @highlight_color = Gosu::Color.rgba(dark_gray.red, dark_gray.green, dark_gray.blue, 100)
        @selection_color = Gosu::Color.rgba(blue.red, blue.green, blue.blue, 100)
      end

      def draw
        highlight_activeline
        # highlight_selection
        Gosu.draw_rect(@text.x + @x, @text.y + @y, 1, @text.height, light_gray) if @show
      end

      def update
        if (Gosu.milliseconds - @last_blink) > @blink_interval
          @last_blink = Gosu.milliseconds
          @show = !@show
        end

        update_caret
        make_visible

        @last_position = position
      end

      def button_up(id)
        # FIXME: Can't seem to get cursor position before it's set to 0...
        # CAUTION: This randomly started working!
        #          And then stopped...?
        line = @newline_data[@active_line]

        if id == Gosu::KbHome
          pos  = line[:position_end_of_line] - line[:text_length]

          set_position(pos)
        end

        if id == Gosu::KbEnd
          pos  = line[:position_end_of_line]

          set_position(pos)
        end
      end

      def build_newline_data
        i = 0
        virt_caret = 0

        @text_input.text.each_line do |line|
          virt_caret += line.length
          @newline_data[i] = {position_end_of_line: virt_caret-1, text: line.chomp, text_length: line.chomp.length} # go behind newline

          i+=1
        end

      end

      def calculate_active_line
        sub_text = @text_input.text[0..position]
        @active_line = sub_text.lines.size-1
      end

      def calculate_x_and_y
        if position == 0
          @x = 0
          return
        end

        line = @text_input.text[0..position-1].lines[@active_line]
        sub_text = ""
        if line
          sub_text = line[0..position-1]
        end

        @x = @text.font.markup_width(sub_text)
        @y = @text.height * @active_line
      end

      def calculate_x_offset
        if @x + window.square_scale > @view.width - @text.x
          @view.x_offset = (@view.width - @text.x) - (@x + window.square_scale)
        else
          @view.x_offset = 0
        end
      end

      def update_caret
        build_newline_data
        calculate_active_line

        calculate_x_and_y
        calculate_x_offset
      end

      def make_visible
        @view.y_offset = @view.height - ((@text.y - (window.container.header_height - (@text.height*2))) + (@active_line * @text.height))
        @view.y_offset = 0 if @view.y_offset > 0
      end

      def highlight_activeline
        Gosu.draw_rect(0 - @view.x_offset, @text.y + (@active_line * @text.height), @view.width, @text.height, @highlight_color)
      end

      def highlight_selection
        line      = @newline_data[@active_line]
        selection = 1000
        selection_x = @text.font.text_width(substring)

        Gosu.draw_rect(@x, @text.y + (@active_line * @text.height), selection_x, @text.height, @selection_color)
      end

      def position
        @text_input.caret_pos
      end

      def set_position(int)
        @text_input.caret_pos = int
        @text_input.selection_start = int # See: https://github.com/gosu/gosu/issues/228
      end

      def select_all
        @text_input.selection_start = 0
        @text_input.caret_pos = @text_input.text.length
      end

      def move(direction)
        pos = @text_input.caret_pos
        active_line = @newline_data[@active_line]
        line = nil

        if direction == :up
          return if @active_line == 0
          line = @newline_data[@active_line-1]

        elsif direction == :down
          return if @text_input.caret_pos == @text_input.text.size
          return unless @newline_data[@active_line+1]
          line = @newline_data[@active_line+1]

        else
          raise ":up or :down please."
        end

        pos = line[:position_end_of_line]

        set_position(pos)
      end
    end
  end
end