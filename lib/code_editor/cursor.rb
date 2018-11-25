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
        @blink_interval = 250
        @show = false

        @newline_data = {}
        @active_line  = 0
        @active_line_history_size  = 2
        @active_line_history_index = 0
        @active_line_history = []

        @highlight_color = Gosu::Color.rgba(dark_gray.red, dark_gray.green, dark_gray.blue, 100)
        @selection_color = Gosu::Color.rgba(blue.red, blue.green, blue.blue, 100)

        caret_stay_left_of_last_newline
      end

      def draw
        highlight_activeline
        # highlight_selection
        Gosu.draw_rect(@text.x + @x, @y, 1, @text.height, light_gray) if @show
      end

      def update
        if (Gosu.milliseconds - @last_blink) > @blink_interval
          @last_blink = Gosu.milliseconds
          @show = !@show
        end

        update_caret
        make_visible

        update_active_line_history
      end

      def button_up(id)
        # FIXME: Can't seem to get cursor position before it's set to 0...
        # CAUTION: This randomly started working!
        #          And then stopped...?

        caret_stay_left_of_last_newline

        case id
        when Gosu::MsLeft
          return unless @view.mouse_inside_view?

          index = row_at(window.mouse_y)
          line  = @newline_data.dig(index)
          return unless line # no line at index
          right_offset = column_at(window.mouse_x - @text.x, window.mouse_y)
          pos = (line[:position_end_of_line] - line[:text_length]) + right_offset

          set_position(pos)

        # TODO: move to button_down? to fix popping to the top and back
        when Gosu::KbHome
          line = @newline_data[last_active_line(0)]
          pos  = line[:position_end_of_line] - line[:text_length]

          set_position(pos)

        # TODO: move to button_down? to fix popping to the bottom and back
        when Gosu::KbEnd
          line = @newline_data[last_active_line(@newline_data.size-1)]
          pos  = line[:position_end_of_line]

          set_position(pos)
        end
      end

      # returns the line of lines from the top that y is at
      def row_at(y)
        return (((y.to_f - window.container.header_height.to_f) - @view.y_offset.to_f) / @text.height).floor
      end

      # returns the column for x on line y
      def column_at(x, y, y_is_line = false)
        x = @text.x if x < x-@text.x
        line  = @newline_data.dig(row_at(y)) unless y_is_line
        line  = @newline_data.dig(y) if y_is_line
        column= 0
        return unless line

        text  = line[:text]
        buffer= ""
        local_x=0

        text.size.times do |i|
          local_x = @text.font.text_width(buffer)

          break if local_x >= x
          column+=1
          buffer+=text.chars[i]
        end

        return column
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
        @y = @text.y + (@active_line * @text.height)

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

      def caret_stay_left_of_last_newline
        @text_input.text+="\n" unless @text_input.text.end_with?("\n")

        eof = @text_input.text.chomp.length
        set_position(eof) if position > eof
      end

      def make_visible
        y_offset = @view.height - ((@text.y - (window.container.header_height - (@text.height*2))) + (@active_line * @text.height))

        if y_offset > 0 # top is visible, reset to 0 to prevent inverse scrolling
          y_offset = 0
        else
          # FIXME
          top    = (@text.y + @view.y_offset.abs) + @text.height
          bottom = (@text.y + @view.y_offset.abs + @view.height) - @text.height * 2

          if (@y).between?(top, bottom) # don't follow cursor up if not at top of screen
            y_offset = @view.y_offset
          elsif @y < top && y_offset <= 0
            y_offset = @view.y_offset + @text.height
          end
        end

        @view.y_offset = y_offset
      end

      def update_active_line_history
        @active_line_history_index = 0 unless @active_line_history_index < @active_line_history_size

        unless @active_line_history[@active_line_history_index-1] == @active_line
          @active_line_history[@active_line_history_index] = @active_line
          @active_line_history_index+=1
        end

      end

      # poison: line index at which home is 0 and end is @newline_data.size-1
      def last_active_line(poison)
        candidate = @active_line

        # p poison

        list = @active_line_history.reject{|l| l == poison}
        return candidate unless list

        # p @active_line_history,list

        candidate = list.reverse.first if list.size > 0

        return candidate
      end

      def highlight_activeline
        Gosu.draw_rect(0 - @view.x_offset, @y, @view.width, @text.height, @highlight_color)
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
        line = nil

        if direction == :up
          return if @active_line == 0
          line  = @newline_data.dig(@active_line-1)
          return unless line # no line at index
          # current_offset = column_at(@x, (@active_line), true) # current line offset
          above_offset = column_at(@x, (@active_line-1), true) # line up offset

          # right_offset = current_offset
          # right_offset = above_offset if current_offset >= above_offset
          right_offset = above_offset

          pos = (line[:position_end_of_line] - line[:text_length]) + right_offset

        elsif direction == :down
          return if @text_input.caret_pos == @text_input.text.size
          return unless @newline_data[@active_line+1]
          line  = @newline_data.dig(@active_line+1)
          return unless line # no line at index
          # current_offset = column_at(@x, (@active_line), true) # current line offset
          below_offset = column_at(@x, (@active_line+1), true) # line down offset

          # right_offset = current_offset
          # right_offset = below_offset if current_offset >= below_offset
          right_offset = below_offset

          pos = (line[:position_end_of_line] - line[:text_length]) + right_offset

        else
          raise ":up or :down please."
        end

        set_position(pos)
      end
    end
  end
end