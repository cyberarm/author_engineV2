class AuthorEngine
  class Part
    module Graphics
      def rect(x = 0, y = 0, width = 1, height = 1, color = Gosu::Color::WHITE, z = 0)
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

      def sprite(index, x = 0, y = 0, z = 0)
        image = SpriteEditor.instance.sprites[index]
        raise "No sprite at '#{index}'!" unless image
        image.draw(x, y, z)
      end

      def translate(x, y, &block)
        Gosu.translate(x, y) do
          block.call if block
        end
      end

      def rotate(angle, around_x = 0, around_y = 0, &block)
        Gosu.rotate(angle, around_x, around_y) do
          block.call if block
        end
      end
    end
  end
end