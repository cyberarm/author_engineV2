class AuthorEngine
  class Window < Gosu::Window
    def self.instance
      @instance
    end

    def self.instance=(_instance)
      @instance = _instance
    end

    def initialize
      super(128, 128, fullscreen: true)
      Window.instance = self
      @container = Container.new
    end

    def draw
      @container.draw
    end

    def update
      @container.update
    end

    def needs_cursor?
      true
    end

    def button_up(id)
      close if id == Gosu::KbEscape

      @container.button_up(id)
    end
  end
end