class AuthorEngine
  class Part
    module OpalGraphics
      def rect(x = 0, y = 0, width = 1, height = 1, color = "white", z = 0)
        `#{@authorengine_canvas_context}.fillStyle = #{color}`
        `#{@authorengine_canvas_context}.fillRect(#{x}, #{y}, #{width}, #{height})`
        return nil
      end

      def sprite(sprite_sheet_index, x = 0, y = 0, z = 0, alpha = 255)
        size = 16 # sprite size
        sprites = AuthorEngine::GameRunner.instance.sprites

        `#{@authorengine_canvas_context}.save()`
        if alpha <= 0
          alpha = 0
        else
          alpha = (alpha / 255.0)
        end
        `#{@authorengine_canvas_context}.globalAlpha = #{alpha}`

        `#{@authorengine_canvas_context}.drawImage(#{sprites[sprite_sheet_index]}, #{x}, #{y})`

        `#{@authorengine_canvas_context}.restore()`
      end

      def text(string, x = 0, y = 0, size = 4, z = 0, color = "white")
        font = "#{size}px Connection, Consolas"
        `#{@authorengine_canvas_context}.font = #{font}`
        `#{@authorengine_canvas_context}.fillStyle = #{color}`
        `#{@authorengine_canvas_context}.textBaseline = "top"`
        `#{@authorengine_canvas_context}.fillText(#{string}, #{x}, #{y})`
      end

      def level(index, z = 0)
        _level = AuthorEngine::GameRunner.instance.levels[index]
        raise "No level at '#{index}'!" unless _level

        _level.each do |sprite|
          sprite(sprite.sprite, sprite.x, sprite.y, z)
        end
      end

      def swap(level, current_sprite, replacement_sprite)
        _level = AuthorEngine::GameRunner.instance.levels[level]
        raise "No level at '#{index}'!" unless _level
        raise "No sprite at '#{current_sprite}'!" unless AuthorEngine::GameRunner.instance.sprites[current_sprite]
        raise "No sprite at '#{replacement_sprite}'!" unless AuthorEngine::GameRunner.instance.sprites[replacement_sprite]

        _level.each {|sprite| sprite.sprite = replacement_sprite if sprite.sprite == current_sprite}
      end

      def translate(x, y, &block)
        `#{@authorengine_canvas_context}.save()`
        `#{@authorengine_canvas_context}.translate(#{x}, #{y})`
        block.call if block
        `#{@authorengine_canvas_context}.restore()`
      end

      def rotate(angle, x = 0, y = 0, &block)
        `#{@authorengine_canvas_context}.save()`
        `#{@authorengine_canvas_context}.translate(#{x}, #{y})`
        `#{@authorengine_canvas_context}.rotate(#{angle})`
        block.call if block
        `#{@authorengine_canvas_context}.restore()`
      end
    end
  end
end