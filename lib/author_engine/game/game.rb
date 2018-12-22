class AuthorEngine
  class Game
    include AuthorEngine::Part::Common
    include AuthorEngine::Part::CollisionDetection
    include AuthorEngine::Part::Colors
    include AuthorEngine::Part::Graphics
    include AuthorEngine::Part::Input

    attr_accessor :scale, :canvas, :canvas_context
    attr_accessor :collision_detection
    def initialize(code:)
      if RUBY_ENGINE == "opal"
        @scale  = 1.0
        @canvas = `document.getElementById('canvas')`
        @canvas_context = `#{@canvas}.getContext('2d')`
      end

      if RUBY_ENGINE != "opal"
        @sprites = SpriteEditor.instance.sprites

        @levels = []
        # Create a "Deep Copy" to allow for swapping of a level's sprites without corrupting LevelEditor's version
        LevelEditor.instance.levels.each do |level|
          @levels << level.sort_by {|sprite| sprite.z}.map {|sprite| sprite.dup}
        end
        size = 16
        @levels.each {|level| level.each {|sprite| sprite.x = sprite.x * size; sprite.y = sprite.y * size}}

        @collision_detection = CollisionDetection.new(@sprites, @levels)

        @sprites.each {|sprite| @collision_detection.add_sprite(sprite) }
        @levels.each {|level| @collision_detection.add_level(level) }
      end

      @background_color = black
      self.instance_eval(code)
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