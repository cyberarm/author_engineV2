class AuthorEngine
  class Part
    module Common
      def width; Window::VIEW_WIDTH; end
      def height; Window::VIEW_HEIGHT; end
      def fps; Gosu.fps; end
      def milliseconds
        @__initial_milliseconds ||= Gosu.milliseconds
        Gosu.milliseconds - @__initial_milliseconds
      end
    end
  end
end