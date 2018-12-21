class AuthorEngine
  class CollisionDetection
    Color = Struct.new(:red, :green, :blue, :alpha)
    BoundingBox = Struct.new(:x, :y, :width, :height)

    def initialize(game_sprites, game_levels)
      @game_sprites = game_sprites
      @game_levels  = game_levels

      @sprites= []
      @levels = []
    end

    def add_sprite(image_or_blob)
      blob = nil
      if defined?(Gosu::Image) && image_or_blob.is_a?(Gosu::Image)
        blob = image_or_blob.to_blob
      else
        blob = image_or_blob
      end

      @sprites << {blob: blob, box: bounding_box(blob)}
    end

    def add_level(level_array)
      @levels << level_array # TODO: Put level's into an optimized structure for fast quadrant look-ups
    end

    def sprite_vs_sprite(sprite_index, sprite_x, sprite_y, target_x, target_y)
    end

    def sprite_vs_level(sprite_index, sprite_x, sprite_y, level)
      detected = []

      collider = @sprites[sprite_index][:box]
      @levels[level].each do |sprite|
        if bounding_boxes_intersect?(collider, sprite_x, sprite_y, @sprites[sprite.sprite][:box], sprite.x, sprite.y)
          detected << sprite
        end
      end

      return detected
    end

    def debug_draw_sprite(sprite_index, sprite_x, sprite_y)
      render_bounding_box(@sprites[sprite_index][:box], sprite_x, sprite_y, Float::INFINITY)
    end

    def debug_draw_level(level_index)
      @levels[level_index].each do |sprite|
        render_bounding_box(@sprites[sprite.sprite][:box], sprite.x, sprite.y, Float::INFINITY)
      end
    end

    private
    def bounding_boxes_intersect?(a, a_x, a_y,  b, b_x, b_y)
      (a.x + a_x) <= (b.x + b_x + b.width)  && (a.x + a_x + a.width)  >= (b.x + b_x) &&
      (a.y + a_y) <= (b.y + b_y + b.height) && (a.y + a_y + a.height) >= (b.y + b_y)
    end

    # returns alpha value of pixel at x and y
    def solid_at?(blob, x, y)
      width = 16

      blob[(y * width + x) * 4 + 3].ord
    end

    def render_bounding_box(box, sprite_x, sprite_y, z = 0, color = 0xc8ff0000)
      if RUBY_ENGINE == "opal"
        warn "rendering bounding boxes with Opal is not yet supported"
        return
      end
      # TOP LEFT TO TOP RIGHT
      Gosu.draw_line(
        box.x + sprite_x, box.y + sprite_y, color,
        box.x + sprite_x + box.width, box.y + sprite_y, color,
        z
      )

      # TOP RIGHT TO BOTTOM RIGHT
      Gosu.draw_line(
        box.x + sprite_x + box.width, box.y + sprite_y, color,
        box.x + sprite_x + box.width, box.y + sprite_y + box.height, color,
        z
      )

      # BOTTOM RIGHT to BOTTOM LEFT
      Gosu.draw_line(
        box.x + sprite_x + box.width, box.y + sprite_y + box.height, color,
        box.x + sprite_x, box.y + sprite_y + box.height, color,
        z
      )

      # BOTTOM LEFT TO TOP LEFT
      Gosu.draw_line(
        box.x + sprite_x, box.y + sprite_y + box.height, color,
        box.x + sprite_x, box.y + sprite_y, color,
        z
      )
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