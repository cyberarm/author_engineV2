class AuthorEngine
  class GameRunner
    def self.instance
      @instance
    end
    def self.instance=(klass)
      @instance = klass
    end

    attr_reader :save_file, :spritesheet, :sprites
    def initialize(project_string)
      AuthorEngine::GameRunner.instance=(self)

      @save_file = AuthorEngine::SaveFile.new(nil)
      @save_file.load(false, project_string)

      @sprites = []
      @spritesheet = nil
      @spritesheet_width  = @save_file.sprites.columns
      @spritesheet_height = @save_file.sprites.rows
      @sprite_size = 16

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

    def run_game
      `window.requestAnimationFrame(function() {#{run_game}})` # placed here to ensure next frame is called even if draw or update throw an error

      if @sprites.size == (@spritesheet_width/@sprite_size)*(@spritesheet_height/@sprite_size)
        draw
        update
      else
        @game.draw_background
        @game.text("Loading sprite #{@sprites.size}/#{(@spritesheet_width/@sprite_size)*(@spritesheet_height/@sprite_size)}.", 0, @game.height/2, 8)
      end

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
      width = spritesheet_data.columns
      height= spritesheet_data.rows
      size  = 16

      temp_canvas = `document.createElement('canvas')`
      temp_canvas_context = `#{temp_canvas}.getContext('2d')`
      `#{temp_canvas}.width  = #{spritesheet_data.columns}`
      `#{temp_canvas}.height = #{spritesheet_data.rows}`

      buffer = `new Uint8ClampedArray(#{spritesheet_data.to_blob})`
      image_data = `new ImageData(#{buffer}, #{width})`
      `#{temp_canvas_context}.putImageData(#{image_data}, 0, 0)`

      @spritesheet = `new Image()`
      `#{@spritesheet}.onload = function() { #{load_sprites} }`
      `#{@spritesheet}.src = #{temp_canvas}.toDataURL()`

    end

    def load_sprites
      spritesheet_data = @save_file.sprites
      width = spritesheet_data.columns
      height= spritesheet_data.rows
      size  = 16

      (height/size).times do |y|
        (width/size).times do |x|
          `createImageBitmap(#{@spritesheet}, #{x * size}, #{y * size}, #{size}, #{size}).then(sprite => { #{@sprites.push(`sprite`)} })`
        end
      end

      return nil
    end

    def show(update_interval = (1000.0 / 60))
      return unless RUBY_ENGINE == "opal"

      `window.addEventListener('resize', () => { #{resize_canvas} })`
      `document.addEventListener('keydown', (event) => { #{AuthorEngine::Part::Input::KEY_STATES[`event.key`] = true} })`
      `document.addEventListener('keyup',   (event) => { #{AuthorEngine::Part::Input::KEY_STATES[`event.key`] = false} })`

      `document.getElementById('loading').style.display = "none"`
      `window.requestAnimationFrame(function() {#{run_game}})`
      return nil
    end
  end
end