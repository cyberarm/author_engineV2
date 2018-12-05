class AuthorEngine
  class GameRunner
    def self.instance
      @instance
    end
    def self.instance=(klass)
      @instance = klass
    end

    attr_reader :save_file, :spritesheet
    def initialize(project_string)
      AuthorEngine::GameRunner.instance=(self)

      @save_file = AuthorEngine::SaveFile.new(nil)
      @save_file.load(false, project_string)

      @game = Game.new(code: @save_file.code)
      build_spritesheet_and_sprites_list
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
      `#{@game.canvas_context}.imageSmoothingEnabled = false`
      return nil
    end

    def build_spritesheet_and_sprites_list
      spritesheet_data = @save_file.sprites

      temp_canvas = `document.createElement('canvas')`
      temp_canvas_context = `#{temp_canvas}.getContext('2d')`
      `#{temp_canvas}.width  = #{spritesheet_data.columns}`
      `#{temp_canvas}.height = #{spritesheet_data.rows}`

      buffer = `new Uint8ClampedArray(#{spritesheet_data.to_blob})`
      image_data = `new ImageData(#{buffer}, #{spritesheet_data.columns})`
      `#{temp_canvas_context}.putImageData(#{image_data}, 0, 0)`

      @spritesheet = `new Image()`
      `#{@spritesheet}.src = #{temp_canvas}.toDataURL()`
    end

    def show(update_interval = (1000.0 / 60))
      return unless RUBY_ENGINE == "opal"

      `window.addEventListener('resize', () => { #{resize_canvas} })`
      `document.addEventListener('keydown', (event) => { #{AuthorEngine::Part::Input::KEY_STATES[`event.key`] = true} })`
      `document.addEventListener('keyup',   (event) => { #{AuthorEngine::Part::Input::KEY_STATES[`event.key`] = false} })`

      `setInterval(function(){#{proc{draw; update}.call}}, #{update_interval})`
      return nil
    end
  end
end