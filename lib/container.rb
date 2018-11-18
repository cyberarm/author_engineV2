class AuthorEngine
  class Container
    include Support

    attr_reader :header_height
    def initialize
      @scale_x = window.scale_x
      @scale_y = window.scale_y

      @active_view  = nil
      @header_height= (16 * @scale_y)+(@scale_y*2)
      @header_color = Gosu::Color.rgba(25, 255, 25, 100)
      @title = Text.new(message: "AuthorEngine", x: (1*@scale_x), y: (1*@scale_y))
      @views = []
      @buttons = []

      @locked = false
    end

    def setup
      add_buttons
    end

    def add_buttons
      @play_viewer   = PlayViewer.new(x: 0, y: @header_height+1, width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(100, 150, 100))
      @sprite_editor = SpriteEditor.new(x: 0, y: @header_height+1, width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(100, 100, 150))
      @level_editor  = LevelEditor.new(x: 0, y: @header_height+1, width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(150, 100, 100))
      @code_editor   = CodeEditor.new(x: 0, y: @header_height+1, width: window.width, height: window.height-@header_height, background: Gosu::Color.rgb(100, 150, 150))

      @buttons << Button.new(image: "assets/ui/play_icon.png", tooltip: "Play", tag: :play_viewer, color: @header_color) {@active_view = @play_viewer; @active_view.focus; @code_editor.blur}
      @buttons << Button.new(image: "assets/ui/sprite_icon.png", tooltip: "Sprite Editor", tag: :sprite_editor, color: @header_color) {@active_view = @sprite_editor; @active_view.focus; @code_editor.blur}
      @buttons << Button.new(image: "assets/ui/level_icon.png", tooltip: "Level Editor", tag: :level_editor, color: @header_color) {@active_view = @level_editor; @active_view.focus; @code_editor.blur}
      @buttons << Button.new(image: "assets/ui/code_icon.png", tooltip: "Code Editor", tag: :code_editor, color: @header_color) {@active_view = @code_editor; @active_view.focus; @code_editor.blur}

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

    def lock; @locked = true; end
    def unlock; @locked = false; end

    def draw
      unless @locked
        Gosu.draw_rect(0, 0, window.width, @header_height, @header_color)
        @title.draw
        @buttons.each(&:draw)
      end

      @active_view.draw if @active_view
    end

    def update
      @active_view.update if @active_view
    end

    def button_up(id)
      @buttons.each {|b| b.button_up(id)} unless @locked

      @active_view.button_up(id) if @active_view
    end
  end
end