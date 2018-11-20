class AuthorEngine
  class PlayViewer < View
    def setup
      @running = false

      @error_icon = Gosu::Image.new("assets/ui/error_icon.png", retro: true)
      @error_icon_color = 0
      @error_icon_colors = [yellow, orange]

      @loading_icon = Gosu::Image.new("assets/ui/loading_icon.png", retro: true)
      @loading_icon_angle = 0
      @loading_icon_rot_step = 45

      @icon_rot_period = 500
      @last_icon_rot = Gosu.milliseconds

      @error_message = Text.new(message: "", x: @x_padding, y: window.container.header_height, z: Float::INFINITY)

      @text = Text.new(message: "Press [Control+P] to Play")
      @text.x = window.width/2 - @text.width/2
      @text.y = window.height/2 + @text.height + @loading_icon.height * window.square_scale

      @last_error = nil
    end

    def run(code: nil)
      @last_error = nil
      @game = Game.new(code: code)

      @running = true
      window.show_cursor = false
      window.container.lock

      @game.init
    end

    def catch_error(&block)
      begin
        block.call if block
      rescue => error
        error_response(error)
      rescue SyntaxError => error
        error_response(error)
      end
    end

    def error_response(error)
      stop

      @last_error = error
      format_error(text: @error_message, error: error)
    end

    def format_error(text:, error:)
      max_width = window.width - (@x_padding*2)
      char_width= text.font.text_width("0")
      chars_line= (max_width.to_f / char_width.to_f).ceil
      p chars_line

      backtrace = "<c=#{xml_color(orange)}>#{error.class}</c>\nBacktrace:\n"
      error.backtrace.each {|trace| next unless trace.include?("(eval)"); backtrace+="  #{trace}\n"}
      trace_buffer = "#{error.message}"
      buffer = ""

      trace_buffer.lines do |line|
        line.chomp.chars.each_slice(chars_line).each do |slice|
          string = slice.join
          p string
          buffer += "  #{string}\n"
        end
      end

      text.message = "#{backtrace}#{buffer}"
    end

    def focus
      window.caption = "Play"
      if Gosu.milliseconds > 100
        play
      end
    end

    def play
      catch_error do
        run(code: code_editor.code)
      end
    end

    def draw
      if @running
        Gosu.draw_rect(0, 0, window.width, window.height, @background)
        Gosu.flush
        catch_error do
          draw_game
        end
      else
        super
        if @last_error
          Gosu.scale(2,2, (window.width / 2) - (@error_icon.width / 2), (window.height / 2) - (@error_icon.height / 2)) do
            @error_icon.draw_rot(window.width / 2, window.height / 2, 10, 0, 0.5, 0.5, 1 * window.square_scale, 1 * window.square_scale, @error_icon_colors[@error_icon_color])
          end
          @error_message.draw_markup
        else
          @loading_icon.draw_rot(window.width / 2, window.height / 2, 10, @loading_icon_angle, 0.5, 0.5, 1 * window.square_scale, 1 * window.square_scale)
          @text.draw
        end
      end
    end

    def update
      # super
      if @running
        catch_error do
          update_game
        end
      else
        if (Gosu.milliseconds - @last_icon_rot) > @icon_rot_period
          @loading_icon_angle = (@loading_icon_angle + @loading_icon_rot_step) % 360
          @error_icon_color += 1
          @error_icon_color = 0 if @error_icon_color == @error_icon_colors.size
          @last_icon_rot = Gosu.milliseconds
        end
      end
    end

    def draw_game
      x_offset = 0
      ratio    = Window::VIEW_WIDTH / window.width
      if window.scale_x != window.scale_y
        x_offset = window.width / 2 - (window.width * ratio * window.square_scale) / 2
      end

      Gosu.clip_to(x_offset, 0, (window.base_size * window.square_scale), (window.base_size * window.square_scale)) do
        Gosu.translate(x_offset, 0) do
          Gosu.scale(window.square_scale, window.square_scale) do
            @game.draw_background
            @game.draw
          end
        end
      end
    end

    def update_game
      @game.update if @game
    end

    def stop
      @running = false
      window.show_cursor = true
      window.container.unlock
    end

    def button_up(id)
      if id == Gosu::MsLeft && window.mouse_x.between?((window.width / 2) - (@loading_icon.width/2) * window.square_scale, (window.width / 2) + (@loading_icon.width/2) * window.square_scale)
        if window.mouse_y.between?((window.height / 2) - (@loading_icon.height/2) * window.square_scale, (window.height / 2) + (@loading_icon.height/2) * window.square_scale)
          play
        end
      end

      stop if id == Gosu::KbEscape
      play if id == Gosu::KbP && window.control_button_down?
    end
  end
end