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

      @collision_detection = AuthorEngine::CollisionDetection.new(@sprites, @levels)
      @game.collision_detection = @collision_detection

      @levels.each {|level| @collision_detection.add_level(level) }

      @game.init

      @show_touch_controls = false
      @touch_buttons = []
      buttons = AuthorEngine::Part::OpalInput::BUTTONS
      key_states = AuthorEngine::Part::OpalInput::KEY_STATES
      @touch_buttons.push(
        TouchButton.new(
          label: "Up", color: @game.dark_gray, x: 137, y: `window.innerHeight/2 - #{125}`, width: 50, height: 50, side: :left,
          contact_proc: proc { key_states[buttons["up"]] = true}, no_contact_proc: proc { key_states[buttons["up"]] = false}
        ),
        TouchButton.new(
          label: "Down", color: @game.dark_gray, x: 137, y: `window.innerHeight/2 + 25`, width: 50, height: 50, side: :left,
          contact_proc: proc { key_states[buttons["down"]] = true}, no_contact_proc: proc { key_states[buttons["down"]] = false}
        ),

        TouchButton.new(
          label: "Left", color: @game.black, x: 175, width: 50, height: 50, side: :left,
          contact_proc: proc { key_states[buttons["left"]] = true}, no_contact_proc: proc { key_states[buttons["left"]] = false}
        ),
        TouchButton.new(
          label: "Right", color: @game.black, x: 100, width: 50, height: 50, side: :left,
          contact_proc: proc { key_states[buttons["right"]] = true}, no_contact_proc: proc { key_states[buttons["right"]] = false}
        ),


        TouchButton.new(
          label: "X", color: @game.red, x: 50, width: 50, height: 50, side: :right,
          contact_proc: proc { key_states[buttons["x"]] = true}, no_contact_proc: proc { key_states[buttons["x"]] = false}
        ),
        TouchButton.new(
          label: "Y", color: @game.yellow, x: 125, width: 50, height: 50, side: :right,
          contact_proc: proc { key_states[buttons["y"]] = true}, no_contact_proc: proc { key_states[buttons["y"]] = false}
        )
      )
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
      @touch_buttons.each(&:draw)
    end

    def update_touch_controls
      active_buttons = []

      @touch_buttons.each do |button|
        @current_touches.each do |id, touch|
          if touch.x.between?(button.x, button.x+button.width) && touch.y.between?(button.y, button.y+button.height)
            active_buttons << button
            button.active
          end
        end
      end

      (@touch_buttons - active_buttons).each(&:inactive)
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
          @collision_detection.add_sprite(`#{temp_canvas_context}.getImageData(0,0, #{size}, #{size}).data`)

          `createImageBitmap(#{@spritesheet}, #{x * size}, #{y * size}, #{size}, #{size}).then(sprite => { #{@sprites.push(`sprite`)} })`
        end
      end

      return nil
    end

    def show(update_interval = (1000.0 / 60))
      return unless RUBY_ENGINE == "opal"

      `window.addEventListener('resize', () => { #{resize_canvas} })`
      `document.addEventListener('keydown', (event) => { #{AuthorEngine::Part::OpalInput::KEY_STATES[`event.key`] = true} })`
      `document.addEventListener('keyup',   (event) => { #{AuthorEngine::Part::OpalInput::KEY_STATES[`event.key`] = false} })`

      `#{@game.canvas}.addEventListener('touchstart',  (event) => { #{@show_touch_controls = true; handle_touch_start(`event`); puts "Touch started..."} })`
      `#{@game.canvas}.addEventListener('touchmove',   (event) => { #{handle_touch_move(`event`); puts "Touch moved..."} })`
      `#{@game.canvas}.addEventListener('touchcancel', (event) => { #{handle_touch_cancel(`event`); puts "Touch canceled."} })`
      `#{@game.canvas}.addEventListener('touchend',    (event) => { #{handle_touch_end(`event`); puts "Touch Ended."} })`

      `document.getElementById('loading').style.display = "none"`
      `window.requestAnimationFrame(function() {#{run_game}})`
      return nil
    end
  end
end