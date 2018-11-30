class AuthorEngine
  class Image
    include AuthorEngine::Support
    CACHE = {}

    def initialize(path, retro: true)
      @retro = retro
      @image = image_from_cache(path)
    end

    def width; @image.width; end
    def height; @image.height; end

    def image_from_cache(path)
      image = nil
      if image = CACHE.dig(path)
        return image
      else
        _image = nil
        begin
          _image = Gosu::Image.new(path, retro: @retro)
        rescue RuntimeError => e
          if e.message.downcase.include?("cannot open file")
            warn e.message
            warn caller[0..2].map{|s| s = "  #{s}"}.reverse
            _image = image_missing
          else
            raise
          end
        end

        image = CACHE[path] = _image
      end

      return image
    end

    def image_missing
      return Gosu.render(window.sprite_size, window.sprite_size) do
        Gosu.draw_rect(0, 0, window.sprite_size, window.sprite_size, Gosu::Color::YELLOW)
        Gosu.draw_rect(2, 2, window.sprite_size-4, window.sprite_size-4, Gosu::Color::RED)
      end
    end

    def draw(*args)
      @image.draw(*args)
    end

    def draw_rot(*args)
      @image.draw_rot(*args)
    end
  end
end