class AuthorEngine
  class Window < Gosu::Window
    def self.instance
      @instance
    end

    def self.instance=(_instance)
      @instance = _instance
    end

    VIEW_WIDTH, VIEW_HEIGHT = 128.0, 128.0

    attr_accessor :show_cursor
    attr_reader :scale_x, :scale_y, :container
    def initialize
      # super(128,128, fullscreen: false)
      super(256, 256, fullscreen: true)
      # super(1280, 800, fullscreen: false)
      # super(Gosu.screen_width, Gosu.screen_height, fullscreen: true)

      Window.instance = self
      @container = nil
      @show_cursor = true
      @scale_x = 1.0
      @scale_y = 1.0

      calculate_scale
      setup
    end

    def setup
      @container = Container.new
    end

    def calculate_scale
      warn "Display is to small! (was #{self.width}x#{self.height} minimum is 128x128)" if self.width < 128 || self.height < 128

      @scale_x = (self.width  / VIEW_WIDTH)
      @scale_y = (self.height / VIEW_HEIGHT)
    end

    def draw
      @container.draw
    end

    def update
      @container.update
    end

    def needs_cursor?
      @show_cursor
    end

    def button_up(id)
      close if id == Gosu::KbEscape

      @container.button_up(id)
    end
  end
end