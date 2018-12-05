class AuthorEngine
  class GameRunner
    def initialize(project_string)
      @save_file = AuthorEngine::SaveFile.new(nil)
      @save_file.load(false, project_string)

      @game = Game.new(code: @save_file.code)
      resize_canvas

      @game.init

      return self
    end

    def draw
      @game.draw_background
      @game.draw
      return nil
    end

    def update
      @game.update
      return nil
    end

    def resize_canvas
      width  = `window.innerWidth`
      height = `window.innerHeight`

      if width < height
        @game.scale = `window.innerWidth / 128.0`
      else
        @game.scale = `window.innerHeight / 128.0`
      end

      `#{@game.canvas}.width  = 128 * #{@game.scale}`
      `#{@game.canvas}.height = 128 * #{@game.scale}`
      `#{@game.canvas}.style.width  = 128 * #{@game.scale}`
      `#{@game.canvas}.style.height = 128 * #{@game.scale}`

      `#{@game.canvas_context}.scale(#{@game.scale}, #{@game.scale})`
      return nil
    end

    def show(update_interval = 16.66667)
      return unless RUBY_ENGINE == "opal"

      `window.addEventListener('resize', () => { #{resize_canvas} })`
      `document.addEventListener('keydown', (event) => { #{AuthorEngine::Part::Input::KEY_STATES[`event.key`] = true} })`
      `document.addEventListener('keyup',   (event) => { #{AuthorEngine::Part::Input::KEY_STATES[`event.key`] = false} })`

      `setInterval(function(){#{proc{draw; update}.call}}, #{update_interval})`
      return nil
    end
  end
end