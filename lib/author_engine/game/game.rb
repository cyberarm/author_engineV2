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

      @sprites = SpriteEditor.instance.sprites
      @levels = []
      # Create a "Deep Copy" to allow for swapping of a level's sprites without corrupting LevelEditor's version
      LevelEditor.instance.levels.each do |level|
        @levels << level.sort_by {|sprite| sprite.z}.map {|sprite| sprite.dup}
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