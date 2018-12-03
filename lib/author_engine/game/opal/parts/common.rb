class AuthorEngine
  class Part
    module Common
      def width; 128; end
      def height; 128; end
      def fps; 0; end
      def milliseconds
        @__initial_milliseconds ||= `performance.now("game")`
        `performance.now("game")` - @__initial_milliseconds
      end
    end
  end
end