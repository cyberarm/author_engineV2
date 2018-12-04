class AuthorEngine
  class Game
    include AuthorEngine::Part::Common
    include AuthorEngine::Part::Colors
    include AuthorEngine::Part::Graphics
    include AuthorEngine::Part::Input

    def initialize(code:)
      if RUBY_ENGINE == "opal"
        @scale  = 1.0
        @canvas = `document.getElementById('canvas')`
        @canvas_context = `#{@canvas}.getContext('2d')`
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