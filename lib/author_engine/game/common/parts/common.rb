class AuthorEngine
  class Part
    module Common
      # returns display width
      def width
        128
      end

      # returns display height
      def height
        128
      end

      # returns frames per seconds
      def fps
        if RUBY_ENGINE == "opal"
          AuthorEngine::GameRunner.instance.fps
        else
          Gosu.fps
        end
      end

      def distance(x1, y1, x2, y2)
        dx = x2 - x1
        dy = y2 - y1

        Math.sqrt(dx * dx + dy * dy)
      end

      def levels
        @authorengine_levels ? @authorengine_levels : AuthorEngine::GameRunner.instance.levels
      end

      # returns number of milliseconds since game started
      def milliseconds
        if RUBY_ENGINE == "opal"
          @__initial_milliseconds ||= `performance.now()`
          (`performance.now()` - @__initial_milliseconds)
        else
          Gosu.milliseconds
        end
      end
    end
  end
end