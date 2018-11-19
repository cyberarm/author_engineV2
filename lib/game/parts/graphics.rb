class AuthorEngine
  class Part
    module Graphics
      def rect(x, y, width, height, color = Gosu::Color::WHITE, z = 0)
        Gosu.draw_rect(x, y, width, height, color, z)
      end

      def text(text, x = 0, y = 0, size = 4, z = 0)
        @fonts ||= {}

        font = nil

        if @fonts.dig(size)
          font = @fonts.dig(size)
        else
          font = (@fonts[size] = Gosu::Font.new(size, name: Text::FONT_DEFAULT))
        end

        font.draw_markup(text, x, y, z)
      end
    end
  end
end