class AuthorEngine
  class Container
    include Support

    def initialize
      @active_view  = nil
      @header_height= 10
      @header_color = Gosu::Color.rgba(25, 255, 25, 100)
      @views = []
      @buttons = []
      add_buttons
    end

    def add_buttons
      v = View.new(x: 0, y: @header_height, width: window.width, height: window.height-@header_height, background: Gosu::Color::GREEN)
      @buttons << Button.new(label: "Play",  color: @header_color) {@active_view = v}

      vi = View.new(x: 0, y: @header_height, width: window.width, height: window.height-@header_height, background: Gosu::Color::BLUE)
      @buttons << Button.new(label: "Sprite",color: @header_color) {@active_view = vi}

      vie = View.new(x: 0, y: @header_height, width: window.width, height: window.height-@header_height, background: Gosu::Color::RED)
      @buttons << Button.new(label: "Map",   color: @header_color) {@active_view = vie}

      view = View.new(x: 0, y: @header_height, width: window.width, height: window.height-@header_height, background: Gosu::Color::YELLOW)
      @buttons << Button.new(label: "Code",  color: @header_color) {@active_view = view}

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
      @buttons.each(&:draw)

      @active_view.draw if @active_view
    end

    def update
      @active_view.update if @active_view
    end

    def button_up(id)
      @buttons.each {|b| b.button_up(id)}

      @active_view.button_up(id)
    end
  end
end