class AuthorEngine
  class Game
    include AuthorEngine::Part::Common
    include AuthorEngine::Part::CollisionDetection
    include AuthorEngine::Part::Colors

    if RUBY_ENGINE == "opal"
      include AuthorEngine::Part::OpalGraphics
      include AuthorEngine::Part::OpalInput
    else
      include AuthorEngine::Part::GosuGraphics
      include AuthorEngine::Part::GosuInput
    end

    attr_accessor :authorengine_scale, :authorengine_canvas, :authorengine_canvas_context
    attr_accessor :authorengine_collision_detection
    def initialize(code:)
      @authorengine_code = code

      if RUBY_ENGINE == "opal"
        @authorengine_scale  = 1.0
        @authorengine_canvas = `document.getElementById('canvas')`
        @authorengine_canvas_context = `#{@authorengine_canvas}.getContext('2d')`
      end

      if RUBY_ENGINE != "opal"
        @authorengine_sprites = SpriteEditor.instance.sprites

        @authorengine_levels = []
        # Create a "Deep Copy" to allow for swapping of a level's sprites without corrupting LevelEditor's version
        LevelEditor.instance.levels.each do |level|
          @authorengine_levels << level.sort_by {|sprite| sprite.z}.map {|sprite| sprite.dup}
        end
        size = 16
        @authorengine_levels.each {|level| level.each {|sprite| sprite.x = sprite.x * size; sprite.y = sprite.y * size}}

        spritesheet = SpriteEditor.instance.spritesheet
        @authorengine_collision_detection = CollisionDetection.new(@authorengine_sprites, @authorengine_levels, SaveFile::SpriteSheetData.new(spritesheet.width, spritesheet.height, spritesheet.to_blob))

        self.instance_eval(code)
      end

      @background_color = black
    end

    def authorengine_eval_code
      self.instance_eval(@authorengine_code)
    end

    def draw_background
      rect(0, 0, width, height, @background_color)
    end

    def init
    end

    def draw
    end

    def update
    end
  end
end