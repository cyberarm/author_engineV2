class AuthorEngine
  class GameRunner
    def self.instance
      @instance
    end
    def self.instance=(klass)
      @instance = klass
    end

    include TouchHandler

    attr_reader :save_file, :spritesheet, :sprites, :levels, :fps
    attr_reader :game
    def initialize(project_string)
      AuthorEngine::GameRunner.instance=(self)

      @save_file = AuthorEngine::SaveFile.new(nil)
      @save_file.load(false, project_string)

      size = 16

      @levels  = @save_file.levels
      @levels.each {|level| level.each {|sprite| sprite.x = sprite.x * size; sprite.y = sprite.y * size}}

      @sprites = []
      @spritesheet = nil
      @spritesheet_width  = @save_file.sprites.columns
      @spritesheet_height = @save_file.sprites.rows
      @sprite_size = 16

      @fps = 0
      @counted_frames = 0
      @frame_count_stated_at = 0

      @game = Game.new(code: @save_file.code)
      build_spritesheet_and_sprites_list
      resize_canvas

      @collision_detection = AuthorEngine::CollisionDetection.new(@sprites, @levels, @save_file.sprites)
      @game.collision_detection = @collision_detection

      @game.init

      @show_touch_controls = false
      @touch_joystick = TouchJoystick.new(x: 100, radius: 50, side: :left)
      @touch_buttons = []
      @touch_buttons.push(
        TouchButton.new(
          label: "X", color: @game.red, x: 50, width: 50, height: 50, side: :right, for_key: "x"
          ),
        TouchButton.new(
          label: "Y", color: @game.yellow, x: 125, width: 50, height: 50, side: :right, for_key: "y"
        )
      )

      @fullscreen_button = TouchButton.new(label: "Fullscreen", color: @game.black, x: 50, y: 10, width: 100, height: 50, side: :right)
      touch_handler_setup

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
      `#{@game.canvas_context}.clearRect(0,0, window.innerWidth, window.innerHeight)`
      `#{@game.canvas_context}.fillStyle = "#222"`
      `#{@game.canvas_context}.fillRect(0,0, window.innerWidth, window.innerHeight)`

      @counted_frames+=1

      if @game.milliseconds - @frame_count_stated_at >= 1000.0
        @fps = @counted_frames
        @frame_count_stated_at = @game.milliseconds
        @counted_frames = 0
      end


      if @sprites.size == (@spritesheet_width/@sprite_size)*(@spritesheet_height/@sprite_size)
        width = 128 * @game.scale

        # `#{@canvas_context}.setTransform(1, 0, 0, 1, 0, 0)`
        `#{@game.canvas_context}.save()`
        `#{@game.canvas_context}.translate(window.innerWidth/2 - #{width/2}, 0)`
        `#{@game.canvas_context}.scale(#{@game.scale}, #{@game.scale})`
        `#{@game.canvas_context}.save()`

        region = `new Path2D()`
        `#{region}.rect(0, 0, 128, 128)`
        `#{@game.canvas_context}.clip(#{region})`
        `#{@game.canvas_context}.save()`
        draw

        `#{@game.canvas_context}.restore()`
        `#{@game.canvas_context}.restore()`
        `#{@game.canvas_context}.restore()`

        update

        if @show_touch_controls
          draw_touch_controls
          update_touch_controls
        end
      else
        @game.draw_background
        @game.text("Loading sprite #{@sprites.size}/#{(@spritesheet_width/@sprite_size)*(@spritesheet_height/@sprite_size)}.", 0, @game.height/2, 8)
      end

      return nil
    end

    def draw_touch_controls
      @fullscreen_button.draw
      @touch_buttons.each(&:draw)
      @touch_joystick.draw
    end

    def update_touch_controls
      @touch_buttons.each { |button| button.trigger?(@current_touches) }
      @touch_joystick.update(@current_touches)
    end

    def reposition_touch_controls
    end

    def resize_canvas
      width  = `window.innerWidth`
      height = `window.innerHeight`

      if width < height
        @game.scale = `window.innerWidth / 128.0`
      else
        @game.scale = `window.innerHeight / 128.0`
      end

      `#{@game.canvas}.width  = #{width}`
      `#{@game.canvas}.height = #{height}`
      `#{@game.canvas}.style.width  = #{width}`
      `#{@game.canvas}.style.height = #{height}`

      `#{@game.canvas_context}.imageSmoothingEnabled = false`

      reposition_touch_controls
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

      temp_canvas = `document.createElement('canvas')`
      temp_canvas_context = `#{temp_canvas}.getContext('2d')`
      `#{temp_canvas}.width  = #{size}`
      `#{temp_canvas}.height = #{size}`

      (height/size).times do |y|
        (width/size).times do |x|
          `#{temp_canvas_context}.clearRect(0,0, #{size}, #{size})`
          `#{temp_canvas_context}.drawImage(#{@spritesheet}, #{x * size}, #{y * size}, #{size}, #{size}, 0, 0, #{size}, #{size})`

          `createImageBitmap(#{@spritesheet}, #{x * size}, #{y * size}, #{size}, #{size}).then(sprite => { #{@sprites.push(`sprite`)} })`
        end
      end

      return nil
    end

    def fullscreen_changed
      resize_canvas
    end

    def show(update_interval = (1000.0 / 60))
      return unless RUBY_ENGINE == "opal"

      `window.addEventListener('resize', () => { #{resize_canvas} })`
      `document.addEventListener('keydown', (event) => { #{@show_touch_controls = false; AuthorEngine::Part::OpalInput::KEY_STATES[`event.key`] = true} })`
      `document.addEventListener('keyup',   (event) => { #{AuthorEngine::Part::OpalInput::KEY_STATES[`event.key`] = false} })`

      `#{@game.canvas}.addEventListener('touchstart',  (event) => { #{@show_touch_controls = true; handle_touch_start(`event`)} })`
      `#{@game.canvas}.addEventListener('touchmove',   (event) => { #{handle_touch_move(`event`)} })`
      `#{@game.canvas}.addEventListener('touchcancel', (event) => { #{handle_touch_cancel(`event`)} })`
      `#{@game.canvas}.addEventListener('touchend',    (event) => { #{handle_touch_end(`event`)} })`

      `#{@game.canvas}.addEventListener('fullscreenchange',    () => { #{fullscreen_changed} })`

      `document.getElementById('loading').style.display = "none"`

      `window.requestAnimationFrame(function() {#{run_game}})`
      return nil
    end
  end
end