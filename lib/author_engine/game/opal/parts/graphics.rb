class AuthorEngine
  class Part
    module Graphics
      def rect(x = 0, y = 0, width = 1, height = 1, color = "white", z = 0)
        `#{@canvas_context}.fillStyle = #{color}`
        `#{@canvas_context}.fillRect(#{x}, #{y}, #{width}, #{height})`
        return nil
      end

      def sprite(sprite_sheet_index, x = 0, y = 0, z = 0, color = "white")
        size = 16 # sprite size
        sprites = AuthorEngine::GameRunner.instance.spritesheet
        `#{@canvas_context}.drawImage(
          #{sprites},
          #{sprite_sheet_index * size},
          0,
          #{size},
          #{size},

          #{x},
          #{y},
          #{size},
          #{size}
          )`
      end

      def text(string, x = 0, y = 0, size = 4, z = 0, color = "white")
        font = "#{size}px Connection, Consolas"
        `#{@canvas_context}.font = #{font}`
        `#{@canvas_context}.fillStyle = #{color}`
        `#{@canvas_context}.textBaseline = "top"`
        `#{@canvas_context}.fillText(#{string}, #{x}, #{y})`
      end

      def translate(x, y, &block)
        `#{@canvas_context}.save()`
        `#{@canvas_context}.translate(#{x}, #{y})`
        block.call if block
        `#{@canvas_context}.restore()`
      end

      def rotate(angle, x = 0, y = 0, &block)
        `#{@canvas_context}.save()`
        `#{@canvas_context}.translate(#{x}, #{y})`
        `#{@canvas_context}.rotate(#{angle})`
        block.call if block
        `#{@canvas_context}.restore()`
      end
    end
  end
end