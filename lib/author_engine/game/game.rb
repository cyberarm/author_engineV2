class AuthorEngine
  class Game
    include AuthorEngine::Part::Common
    include AuthorEngine::Part::Colors
    include AuthorEngine::Part::Graphics
    include AuthorEngine::Part::Input

    attr_accessor :scale, :canvas, :canvas_context

    def initialize(code:)
      if RUBY_ENGINE == "opal"
        @scale  = 1.0
        @canvas = `document.getElementById('canvas')`
        @canvas_context = `#{@canvas}.getContext('2d')`
      end

      @collision_detection = CollisionDetection.new

      @sprites = SpriteEditor.instance.sprites
      @sprites.each do |sprite|
        @collision_detection.add_sprite(sprite.to_blob) if RUBY_ENGINE == "opal"
        @collision_detection.add_sprite(sprite) if RUBY_ENGINE != "opal"
      end

      @levels = []
      # Create a "Deep Copy" to allow for swapping of a level's sprites without corrupting LevelEditor's version
      LevelEditor.instance.levels.each do |level|
        @levels << level.sort_by {|sprite| sprite.z}.map {|sprite| sprite.dup}
      end
      @levels.each {|level| @collision_detection.add_level(level)}

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