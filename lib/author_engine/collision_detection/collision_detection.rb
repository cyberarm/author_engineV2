class AuthorEngine
  class CollisionDetection
    Color = Struct.new(:red, :green, :blue, :alpha)
    BoundingBox = Struct.new(:x, :y, :width, :height)

    def initialize
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
    end

    def sprite_vs_sprite(sprite_index, sprite_x, sprite_y, target_x, target_y)
    end

    def sprite_vs_level(sprite_index, sprite_x, sprite_y, level)
    end

    private
    # returns color
    def get_pixel(blob, x, y)
      width = 16
      p blob[(y * width + x) * 4]
    end

    def bounding_box(blob, size = 16)
      box = BoundingBox.new(size, size, 0, 0)
      size.times do |y|
        size.times do |x|
          if get_pixel(blob, x, y).alpha > 0
            box.x = x if x < box.x
            box.y = y if y < box.y
            box.width  = x if x > box.width
            box.height = y if y > box.height
          end
        end
      end

      return box
    end
  end
end