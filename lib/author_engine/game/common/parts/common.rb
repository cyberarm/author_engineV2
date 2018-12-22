class AuthorEngine
  class Part
    module Common
      def width
        128
      end

      def height
        128
      end

      def fps
        if RUBY_ENGINE == "opal"
          AuthorEngine::GameRunner.instance.fps
        else
          Gosu.fps
        end
      end

      def milliseconds
        if RUBY_ENGINE == "opal"
          @__initial_milliseconds ||= `performance.now()`
          (`performance.now()` - @__initial_milliseconds).round(3)
        else
          Gosu.milliseconds
        end
      end
    end
  end
end