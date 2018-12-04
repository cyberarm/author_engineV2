class AuthorEngine
  class GameRunner
    def initialize(project_string)
      @save_file = SaveFile.new(nil).load(false, project_string)
      @game = Game.new(code: @save_file.code)
      return nil
    end

    def draw
    `#{@canvas_context}.scale(#{@scale}, #{@scale})`

      @game.draw_background
      @game.draw
      return nil
    end

    def update
      size_canvas
      @game.update
      return nil
    end

    def size_canvas
      width  = `window.innerWidth`
      height = `window.innerHeight`

      if width < height
        @scale = `window.innerWidth / 128.0`
      else
        @scale = `window.innerHeight / 128.0`
      end


      `#{@canvas}.width  = 128 * #{@scale}`
      `#{@canvas}.height = 128 * #{@scale}`
      `#{@canvas}.style.width  = 128 * #{@scale}`
      `#{@canvas}.style.height = 128 * #{@scale}`
      return nil
    end

    def show(update_interval = 16.66667)
      return unless RUBY_ENGINE == "opal"

      `setInterval(function(){#{proc{draw; update}.call}}, #{update_interval})`
      return nil
    end
  end
end