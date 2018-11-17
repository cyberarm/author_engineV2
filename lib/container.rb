class AuthorEngine
  class Container
    include Support

    def initialize
      @scale_x = window.scale_x
      @scale_y = window.scale_y

      @active_view  = nil
      @header_height= (10 * @scale_y)
      @header_color = Gosu::Color.rgba(25, 255, 25, 100)
      @title = Text.new(message: "AuthorEngine", x: (1*@scale_x), y: (1*@scale_y))
      @views = []
      @buttons = []
      add_buttons
    end

    def add_buttons
      @play_viewer = View.new(x: 0, y: @header_height+(@scale_y*2), width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(100, 150, 100))
      @buttons << Button.new(label: "►", tooltip: "Play", color: @header_color) {@active_view = @play_viewer}

      @sprite_editor = SpriteEditor.new(x: 0, y: @header_height+(@scale_y*2), width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(100, 100, 150))
      @buttons << Button.new(label: "☃", tooltip: "Sprite Editor", color: @header_color) {@active_view = @sprite_editor; window.show_cursor = true}

      @level_editor = View.new(x: 0, y: @header_height+(@scale_y*2), width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(150, 100, 100))
      @buttons << Button.new(label: "░", tooltip: "Level Editor", color: @header_color) {@active_view = @level_editor}

      @code_editor = View.new(x: 0, y: @header_height+(@scale_y*2), width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(100, 150, 150))
      @buttons << Button.new(label: "❞", tooltip: "Code Editor", color: @header_color) {@active_view = @code_editor}

      @active_view = @play_viewer
      @active_view.focus
      position_buttons
    end

    def position_buttons
      total_width = 0
      @buttons.each do |b|
        total_width+=b.width
      end
      raise "Header buttons are to wide (#{total_width})" if total_width > window.width


      origin = window.width - total_width
      x_offset = 0
      @buttons.each_with_index do |b, i|
        b.x = origin + x_offset
        x_offset+=b.width
      end
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, @header_height, @header_color)
      @title.draw
      @buttons.each(&:draw)

      @active_view.draw if @active_view
    end

    def update
      @active_view.update if @active_view
    end

    def button_up(id)
      @buttons.each {|b| b.button_up(id)}

      @active_view.button_up(id) if @active_view
    end
  end
end