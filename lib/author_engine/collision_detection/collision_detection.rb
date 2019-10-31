class AuthorEngine
  class CollisionDetection
    Color = Struct.new(:red, :green, :blue, :alpha)
    BoundingBox = Struct.new(:x, :y, :width, :height)

    def initialize(game_sprites, game_levels, spritesheet)
      @game_sprites = game_sprites
      @game_levels  = game_levels

      @sprites= []
      @levels = []

      @known_collisions = []

      if RUBY_ENGINE != "opal"
        spritesheet.to_blob.chars.each_slice(16 * 16 * 4) do |blob|
          add_sprite(blob)
        end
      else
        spritesheet.to_blob.each_slice(16 * 16 * 4) do |blob|
          add_sprite(blob)
        end
      end

      @game_levels.each { |level| add_level(level) }
    end

    def clear
      @known_collisions.clear
    end

    def add_sprite(blob)
      @sprites << {blob: blob, box: bounding_box(blob)}
    end

    def add_level(level_array)
      @levels << level_array # TODO: Put level's into an optimized structure for fast quadrant look-ups
    end

    def box(sprite_index)
      @sprites[sprite_index][:box]
    end

    def sprite_vs_sprite(sprite_index, sprite_x, sprite_y, target_sprite_index, target_x, target_y)
      bounding_boxes_intersect?(box(sprite_index), sprite_x, sprite_y, box(target_sprite_index), target_x, target_y)
    end

    def sprite_vs_level(sprite_index, sprite_x, sprite_y, level)
      detected = []

      collider = box(sprite_index)
      @levels[level].each do |sprite|
        if bounding_boxes_intersect?(collider, sprite_x, sprite_y, box(sprite.sprite), sprite.x, sprite.y)
          detected << sprite
        end
      end

      return detected
    end

    def colliding_edge(sprite_index, sprite_x, sprite_y, target_sprite_index, target_x, target_y)
      sprite_box = box(sprite_index)
      target_box = box(target_sprite_index)

      edges = {top: false, left: false, right: false, bottom: false}

      # https://gamedev.stackexchange.com/a/24091
      wy = (sprite_box.width + target_box.width) * ((sprite_y - sprite_box.height) - (target_y - target_box.height/2));
      hx = (sprite_box.height + target_box.height) * ((sprite_x - sprite_box.width) - (target_x - target_box.height/2));

      if (wy > hx)
        if (wy > -hx)
          edges[:bottom] = true
        else
          edges[:left] = true
        end
      else
        if (wy > -hx)
          edges[:right] = true
        else
          edges[:top] = true
        end
      end

      return edges
    end

    def debug_draw_sprite(sprite_index, sprite_x, sprite_y)
      render_bounding_box(sprite_index, box(sprite_index), sprite_x, sprite_y)
    end

    def debug_draw_level(level_index)
      @levels[level_index].each do |sprite|
        render_bounding_box(sprite.sprite, box(sprite.sprite), sprite.x, sprite.y)
      end
    end

    def render_bounding_box(sprite_index, box, sprite_x, sprite_y, edges = {}, z = Float::INFINITY, color = 0xc800ff00, collision_color = 0xc8ff00ff)
      if RUBY_ENGINE == "opal"
        color = "green"
        collision_color = "purple"
      end
      paint_color = color
      # EDGE: TOP
      # TOP LEFT TO TOP RIGHT
      if edges[:top] then paint_color = collision_color; else paint_color = color; end
      draw_line(
        box.x + sprite_x, box.y + sprite_y,
        box.x + sprite_x + box.width, box.y + sprite_y,
        paint_color, z
      )

      # EDGE: RIGHT
      # TOP RIGHT TO BOTTOM RIGHT
      if edges[:right] then paint_color = collision_color; else paint_color = color; end
      draw_line(
        box.x + sprite_x + box.width, box.y + sprite_y,
        box.x + sprite_x + box.width, box.y + sprite_y + box.height,
        paint_color, z
      )

      # EDGE: BOTTOM
      # BOTTOM RIGHT to BOTTOM LEFT
      if edges[:bottom] then paint_color = collision_color; else paint_color = color; end
      draw_line(
        box.x + sprite_x + box.width, box.y + sprite_y + box.height,
        box.x + sprite_x, box.y + sprite_y + box.height,
        paint_color, z
      )

      # EDGE: LEFT
      # BOTTOM LEFT TO TOP LEFT
      if edges[:left] then paint_color = collision_color; else paint_color = color; end
      draw_line(
        box.x + sprite_x, box.y + sprite_y + box.height,
        box.x + sprite_x, box.y + sprite_y,
        paint_color, z
      )
    end

    private
    def bounding_boxes_intersect?(a, a_x, a_y,  b, b_x, b_y)
      (a.x + a_x) <= (b.x + b_x + b.width)  && (a.x + a_x + a.width)  >= (b.x + b_x) &&
      (a.y + a_y) <= (b.y + b_y + b.height) && (a.y + a_y + a.height) >= (b.y + b_y)
    end

    def draw_line(x, y, x2, y2, color, z = 0)
      if RUBY_ENGINE == "opal"
        `#{AuthorEngine::GameRunner.instance.game.canvas_context}.strokeStyle = #{color}`
        `#{AuthorEngine::GameRunner.instance.game.canvas_context}.lineWidth = 1`

        `#{AuthorEngine::GameRunner.instance.game.canvas_context}.beginPath()`
        `#{AuthorEngine::GameRunner.instance.game.canvas_context}.moveTo(#{x}, #{y})`
        `#{AuthorEngine::GameRunner.instance.game.canvas_context}.lineTo(#{x2}, #{y2})`
        `#{AuthorEngine::GameRunner.instance.game.canvas_context}.stroke()`
      else
        Gosu.draw_line(x, y, color, x2, y2, color, z)
      end
    end

    # returns alpha value of pixel at x and y
    def solid_at?(blob, x, y)
      width = 16

      blob[(y * width + x) * 4 + 3].ord
    end

    def bounding_box(blob, size = 16)
      box = BoundingBox.new(size, size, 0, 0)
      size.times do |y|
        size.times do |x|
          if solid_at?(blob, x, y) > 0
            box.x = x if x < box.x
            box.y = y if y < box.y
            box.width  = x if x > box.width
            box.height = y if y > box.height
          end
        end
      end

      # Correct width/height
      box.width  -= box.x
      box.height -= box.y

      # Correct off-by-1
      box.width  += 1
      box.height += 1

      return box
    end
  end
end