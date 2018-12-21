class AuthorEngine
  class SaveFile
    SpriteSheetData = Struct.new(:columns, :rows, :to_blob)

    def self.create(file)
      if File.exists?(file)
        return false
      else
        File.open(file, "w") {|f| f.write ""}
        if File.exists?(file)
          return true
        else
          return false
        end
      end
    end

    attr_reader :file
    attr_reader :code, :sprites, :levels
    def initialize(file)
      @file = file
      @buffer = ""

      @code, @sprites, @levels = nil, nil, nil

      load unless RUBY_ENGINE == "opal"
    end

    def save
      save_code
      save_spritesheet
      save_levels

      File.open(@file, "w") do |f|
        f.write @buffer
      end

      @buffer = ""
      puts "Saved #{file}"
    end

    def save_code
      @buffer+= "___CODE___\n"
      @buffer+= CodeEditor.instance.code
      # @buffer+="\n" # CodeEditor always has this newline
    end

    def save_spritesheet
      sheet = SpriteEditor.instance.spritesheet

      @buffer+= "___SPRITES___\n"
      @buffer+="#{sheet.width}x#{sheet.height}"
      @buffer+="\n"

      pack = sheet.to_blob.unpack('H*').first
      # @buffer+= pack
      pack.chars.each_slice(1024) do |slice|
        @buffer+=slice.join
        @buffer+="\n"
      end

      @buffer+="\n"
    end

    def save_levels
      @buffer+= "___LEVELS___\n"
      LevelEditor.instance.levels.each do |level|
        @buffer+= "#{level.map {|s| "#{s.sprite},#{s.x},#{s.y},#{s.z}"}.join(",")}\n"
      end
      @buffer.strip # Level is the last element saved
    end

    def load(from_file = true, data = nil)
      string = ""
      if from_file
        File.open(@file, "r") {|f| string = f.read}
      else
        string = data
      end

      load_code(string)
      load_spritesheet(string)
      load_levels(string)
    end

    def load_code(string)
      buffer = ""
      in_code= false
      string.each_line do |line|
        if line.start_with?("___CODE___")
          in_code = true
          next
        end
        if line.start_with?("___") && in_code
          break
        end

        buffer+="#{line}" if in_code
      end

      @code = buffer
    end

    def load_spritesheet(string)
      buffer = ""
      width  = 0
      height = 0
      in_sprites = false

      string.each_line do |line|
        if line.strip.start_with?("___SPRITES___")
          in_sprites = true
          next
        end
        if line.start_with?("___") && in_sprites
          break
        end

        next unless in_sprites

        if line.include?("x")
          a = line.strip.split("x")
          width = a.first.to_i
          height = a.last.to_i
          next
        end


        buffer += line.strip
      end

      stream = nil
      if RUBY_ENGINE != "opal"
        stream = buffer.scan(/../).map { |x| x.hex }.pack('c*')
      else
        stream = buffer.scan(/../).map { |x| Integer(x.hex) }
      end

      @sprites = SpriteSheetData.new(width, height, stream)
    end

    def load_levels(string)
      levels   = []
      in_level = false

      string.each_line do |line|
        if line.start_with?("___LEVELS___")
          in_level = true
          next
        end
        if line.start_with?("___") && in_level
          break
        end

        if in_level
          level = []
          # 0 - Sprite, 1 - X, 2 - Y, 3 - Z
          line.strip.split(",").each_slice(4) do |sprite|
            level << Sprite.new(Integer(sprite[0]), Integer(sprite[1]), Integer(sprite[2]), Integer(sprite[3]))
          end
          levels << level
        end
      end

      @levels = levels
    end
  end
end