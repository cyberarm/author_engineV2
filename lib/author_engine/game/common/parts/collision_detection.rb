class AuthorEngine
  class Part
    module CollisionDetection
      def bounding_box(sprite_index)
        @collision_detection.box(sprite_index)
      end

      def colliding_edge(sprite_index, sprite_x, sprite_y, target_sprite_index, target_x, target_y)
        @collision_detection.colliding_edge(sprite_index, sprite_x, sprite_y, target_sprite_index, target_x, target_y)
      end

      def sprite_vs_sprite(sprite_index, sprite_x, sprite_y, target_sprite_index, target_x, target_y)
        @collision_detection.sprite_vs_sprite(sprite_index, sprite_x, sprite_y, target_sprite_index, target_x, target_y)
      end

      def sprite_vs_level(sprite_index, sprite_x, sprite_y, level)
        @collision_detection.sprite_vs_level(sprite_index, sprite_x, sprite_y, level)
      end

      def draw_sprite_box(sprite_index, sprite_x, sprite_y)
        @collision_detection.debug_draw_sprite(sprite_index, sprite_x, sprite_y)
      end

      def draw_level_boxes(level_index)
        @collision_detection.debug_draw_level(level_index)
      end

      def render_bounding_box(sprite_index, box, sprite_x, sprite_y, edges = {}, z = Float::INFINITY)
        @collision_detection.render_bounding_box(sprite_index, box, sprite_x, sprite_y, edges, z, nil, nil)
      end
    end
  end
end