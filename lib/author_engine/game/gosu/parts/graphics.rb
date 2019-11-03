class AuthorEngine
  class Part
    module GosuGraphics
      def rect(x = 0, y = 0, width = 1, height = 1, color = Gosu::Color::WHITE, z = 0)
        Gosu.draw_rect(x, y, width, height, color, z)
      end

      def text(text, x = 0, y = 0, size = 4, z = 0, color = white)
        @authorengine_fonts ||= {}

        font = nil

        if @authorengine_fonts.dig(size)
          font = @authorengine_fonts.dig(size)
        else
          font = (@authorengine_fonts[size] = Gosu::Font.new(size, name: Text::FONT_DEFAULT))
        end

        font.draw_markup(text, x, y, z, 1, 1, color)
      end

      def sprite(index, x = 0, y = 0, z = 0, alpha = 255)
        image = @authorengine_sprites[index]
        raise "No sprite at '#{index}'!" unless image
        image.draw(x, y, z, 1,1, Gosu::Color.rgba(255,255,255, alpha))
      end

      def level(index, z = 0)
        _level = @authorengine_levels[index]
        raise "No level at '#{index}'!" unless _level

        _level.each do |sprite|
          sprite(sprite.sprite, sprite.x, sprite.y, z)
        end
      end

      def swap(level, current_sprite, replacement_sprite)
        _level = @authorengine_levels[level]
        raise "No level at '#{index}'!" unless _level
        raise "No sprite at '#{current_sprite}'!" unless @authorengine_sprites[current_sprite]
        raise "No sprite at '#{current_sprite}'!" unless @authorengine_sprites[replacement_sprite]

        _level.each {|sprite| sprite.sprite = replacement_sprite if sprite.sprite == current_sprite}
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