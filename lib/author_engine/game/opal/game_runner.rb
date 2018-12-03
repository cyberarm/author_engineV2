class AuthorEngine
  class GameRunner
    def initialize
      @save_file = SaveFile.new(nil).load(false, "")
      @game = Game.new(code: @save_file.code)
    end

    def draw
      @game.draw_background
      @game.draw
    end

    def update
      @game.update
    end
  end
end