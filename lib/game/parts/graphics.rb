class AuthorEngine
  class Part
    module Graphics
      def rect(x, y, width, height, color = Gosu::Color::WHITE, z = 0)
        Gosu.draw_rect(x, y, width, height, color, z)
      end
    end
  end
end