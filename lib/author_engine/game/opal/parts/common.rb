class AuthorEngine
  class Part
    module Common
      def width; 128; end
      def height; 128; end
      def fps; 0; end
      def milliseconds
        @__initial_milliseconds ||= `performance.now()`
        (`performance.now()` - @__initial_milliseconds).round(3)
      end
    end
  end
end