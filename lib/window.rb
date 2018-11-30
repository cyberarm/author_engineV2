class AuthorEngine
  class Window < Gosu::Window
    def self.instance
      @instance
    end

    def self.instance=(_instance)
      @instance = _instance
    end

    VIEW_WIDTH, VIEW_HEIGHT, SIZE = 128.0, 128.0, 128.0

    attr_accessor :show_cursor
    attr_reader :scale_x, :scale_y, :square_scale, :base_size, :container, :sprite_size
    def initialize
      super(512, 512, fullscreen: false)
      super(512, 512, fullscreen: true) if ARGV.join.include?("--fullscreen")
      # super(1280, 800, fullscreen: false)
      super(Gosu.screen_width, Gosu.screen_height, fullscreen: true) if ARGV.join.include?("--native")

      Window.instance = self
      @container = nil
      @show_cursor = true
      @scale_x = 1.0
      @scale_y = 1.0
      @square_scale = 1.0
      @base_size = SIZE

      @sprite_size = 16

      @close_counter = 0

      calculate_scale
      setup
    end

    def setup
      self.container=(Loader.new)
    end

    def container=(container)
      if container.is_a?(Container)
        @container = container
        @container.setup
      end
    end

    def calculate_scale
      warn "Display is to small! (was #{self.width}x#{self.height} minimum is 128x128)" if self.width < 128 || self.height < 128

      @scale_x = (self.width  / VIEW_WIDTH)
      @scale_y = (self.height / VIEW_HEIGHT)

      @square_scale = @scale_y
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

    def lighten(color, amount = 25)
      if defined?(color.alpha)
        return Gosu::Color.rgba(color.red+amount, color.green+amount, color.blue+amount, color.alpha)
      else
        return Gosu::Color.rgb(color.red+amount, color.green+amount, color.blue+amount)
      end
    end

    def darken(color, amount = 25)
      if defined?(color.alpha)
        return Gosu::Color.rgba(color.red-amount, color.green-amount, color.blue-amount, color.alpha)
      else
        return Gosu::Color.rgb(color.red-amount, color.green-amount, color.blue-amount)
      end
    end

    def control_button_down?
      (Gosu.button_down?(Gosu::KbLeftControl) || Gosu.button_down?(Gosu::KbRightControl))
    end

    def alt_button_down?
      (Gosu.button_down?(Gosu::KbLeftAlt) || Gosu.button_down?(Gosu::KbRightAlt))
    end

    def shift_button_down?
      (Gosu.button_down?(Gosu::KbLeftShift) || Gosu.button_down?(Gosu::KbRightShift))
    end

    def save_and_exit
      if @container.is_a?(Editor)
        @container.savefile.save
      end

      close!
    end

    def close
      if @container
        @container.close
      else
        super
      end
    end

    def button_down(id)
      super

      @container.button_down(id)
    end

    def button_up(id)
      super

      if id == Gosu::KbEscape
        @close_counter += 1
        save_and_exit if @close_counter == 2
      else
        @close_counter = 0
      end

      @container.button_up(id)
    end
  end
end