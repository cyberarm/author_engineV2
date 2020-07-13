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

      @sprites = []
      @spritesheet = nil
      @spritesheet_width  = @save_file.sprites.columns
      @spritesheet_height = @save_file.sprites.rows
      @sprite_size = 16

      @game = Game.new(code: @save_file.code)
      resize_canvas

      @fps = 0
      @counted_frames = 0
      @frame_count_stated_at = 0

      @show_touch_controls = false

      @game_loaded = false

      @loader_tasks = [
        [
          "Loading levels",
          proc {
            @levels  = @save_file.levels
            @levels.each {|level| level.each {|sprite| sprite.x = sprite.x * @sprite_size; sprite.y = sprite.y * @sprite_size}}
          }
        ],

        [
          "Evaluating game",
          proc {
            @game.authorengine_eval_code
          },
        ],

        [
          "Loading sprites",
          proc {
            build_spritesheet_and_sprites_list
          },
        ],

        [
          "Setting up collision detection",
          proc {
            @collision_detection = AuthorEngine::CollisionDetection.new(@sprites, @levels, @save_file.sprites)
            @game.authorengine_collision_detection = @collision_detection
          },
        ],

        [
          "Initializing game",
          proc {
            @game.init
          },
        ],

        [
          "Setting up touch controls",
          proc {
            @touch_joystick = TouchJoystick.new(radius: 50)
            @touch_buttons = []
            @touch_buttons.push(
              TouchButton.new(
                label: "X", color: @game.red, width: 50, height: 50, for_key: "x"
                ),
              TouchButton.new(
                label: "Y", color: @game.yellow, width: 50, height: 50, for_key: "y"
              )
            )

            @fullscreen_button = TouchButton.new(label: "Fullscreen", color: @game.black, width: 100, height: 50)
            touch_handler_setup
            reposition_touch_controls
          },
        ],

        [
          "Loading done",
          proc {
            @game_loaded = true
          },
        ],
      ]

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
      width  = `window.innerWidth`
      height = `window.innerHeight`
      game_width = 128 * @game.authorengine_scale
      game_height = 128 * @game.authorengine_scale

      area_width  = (`window.innerWidth` - game_width) / 2

      `#{@game.authorengine_canvas_context}.clearRect(#{area_width},0, #{game_width}, #{game_height})`

      @counted_frames+=1

      if @game.milliseconds - @frame_count_stated_at >= 1000.0
        @fps = @counted_frames
        @frame_count_stated_at = @game.milliseconds
        @counted_frames = 0
      end

      `#{@game.authorengine_canvas_context}.save()`
      `#{@game.authorengine_canvas_context}.translate(window.innerWidth/2 - #{game_height/2}, 0)`
      `#{@game.authorengine_canvas_context}.scale(#{@game.authorengine_scale}, #{@game.authorengine_scale})`
      `#{@game.authorengine_canvas_context}.save()`

      region = `new Path2D()`
      `#{region}.rect(0, 0, 128, 128)`
      `#{@game.authorengine_canvas_context}.clip(#{region})`
      `#{@game.authorengine_canvas_context}.save()`


      if @game_loaded or @loader_tasks.empty?
        draw
        `#{@game.authorengine_canvas_context}.restore()`
        `#{@game.authorengine_canvas_context}.restore()`
        `#{@game.authorengine_canvas_context}.restore()`

        update

        if @show_touch_controls
          draw_touch_controls
          update_touch_controls
        end

      else
        task = @loader_tasks.shift
        @game.rect(0, 0, @game.width, @game.height, @game.dark_purple)
        @game.text("AuthorEngine v#{AuthorEngine::VERSION}", 2, @game.height / 2 - 20, 10)
        @game.text("#{task[0]}...", 6, @game.height / 2 - 4, 8, 0, @game.light_gray)
        @game.text("Empowered by Opal v#{Opal::VERSION}, a Ruby interpeter.", 4, @game.height - 6, 4, 0, @game.indigo)

        `#{@game.authorengine_canvas_context}.restore()`
        `#{@game.authorengine_canvas_context}.restore()`
        `#{@game.authorengine_canvas_context}.restore()`

        task[1].call
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
      return nil unless @touch_joystick

      width  = `window.innerWidth`
      height = `window.innerHeight`
      game_width = 128 * @game.authorengine_scale
      game_height = 128 * @game.authorengine_scale

      # place controls under game
      if width < height
        area_width  = width
        area_height = height - game_height

        puts "space: width #{area_width} x height #{area_height}"

        @touch_joystick.x = @touch_joystick.radius + @touch_joystick.radius
        @touch_joystick.y = game_height + area_height / 2

        padding = 10
        last_x = 20
        @touch_buttons.reverse.each do |button|
          button.x = width - (last_x + button.width)
          button.y = (height - area_height) + area_height / 2 - button.height / 2

          last_x += button.width + padding
        end

        @fullscreen_button.x = width - (width / 2 + @fullscreen_button.width / 2)
        @fullscreen_button.y = height - @fullscreen_button.height

      # place controls beside game
      else
        area_width  = (`window.innerWidth` - game_width) / 2
        area_height = game_height

        puts "space: width #{area_width} x height #{area_height}"

        @touch_joystick.x = @touch_joystick.radius + @touch_joystick.radius
        @touch_joystick.y = game_height / 2

        padding = 10
        last_x = 50
        @touch_buttons.reverse.each do |button|
          button.x = width - (last_x + button.width)
          button.y = game_height / 2 - button.height / 2

          last_x += button.width + padding
        end

        @fullscreen_button.x = width - @fullscreen_button.width
        @fullscreen_button.y = 0
      end

      return nil
    end

    def resize_canvas
      width  = `window.innerWidth`
      height = `window.innerHeight`

      if width < height
        @game.authorengine_scale = `#{width} / 128.0`
      else
        @game.authorengine_scale = `#{height} / 128.0`
      end

      `#{@game.authorengine_canvas}.width  = #{width}`
      `#{@game.authorengine_canvas}.height = #{height}`
      `#{@game.authorengine_canvas}.style.width  = #{width}`
      `#{@game.authorengine_canvas}.style.height = #{height}`

      `#{@game.authorengine_canvas_context}.imageSmoothingEnabled = false`

      reposition_touch_controls
      `#{@game.authorengine_canvas_context}.clearRect(0, 0, window.innerWidth, window.innerHeight)`
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

      `#{@game.authorengine_canvas}.addEventListener('touchstart',  (event) => { #{@show_touch_controls = true; handle_touch_start(`event`)} })`
      `#{@game.authorengine_canvas}.addEventListener('touchmove',   (event) => { #{handle_touch_move(`event`)} })`
      `#{@game.authorengine_canvas}.addEventListener('touchcancel', (event) => { #{handle_touch_cancel(`event`)} })`
      `#{@game.authorengine_canvas}.addEventListener('touchend',    (event) => { #{handle_touch_end(`event`)} })`

      `#{@game.authorengine_canvas}.addEventListener('fullscreenchange',    () => { #{fullscreen_changed} })`

      `document.getElementById('loading').style.display = "none"`

      `window.requestAnimationFrame(function() {#{run_game}})`
      return nil
    end
  end
end