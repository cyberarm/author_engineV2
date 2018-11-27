class AuthorEngine
  class Part
    module Common
      def width; Window::VIEW_WIDTH; end
      def height; Window::VIEW_HEIGHT; end
      def milliseconds; Gosu.milliseconds; end
    end
  end
end