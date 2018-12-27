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

    attr_reader :file, :mode
    attr_reader :code, :sprites, :levels
    def initialize(file)
      @file = file
      @buffer = ""
      @mode = :compact # or :inflated

      @code, @sprites, @levels = nil, nil, nil

      load unless RUBY_ENGINE == "opal"
    end

    def save
      @buffer = "# inflated\n" if inflated?
      save_code
      save_spritesheet
      save_levels

      File.open(@file, "w") do |f|
        f.write @buffer
      end

      @buffer = ""
      puts "Saved #{file}"
    end

    def inflate!
      load
      @mode = :inflated
      save_code(@code)
      save_spritesheet(Gosu::Image.new(@sprites, retro: true))

      file = File.read(@file)
      unless file.lines.first.include?("# inflated")
        File.open(@file, "w") do |f|
          f.write "# inflated\n"
          f.write file
        end
      end

    end

    def inflated?
      @mode == :inflated
    end

    def project_name
      File.basename(@file, ".authorengine")
    end

    def project_path
      File.expand_path(@file).sub(File.basename(@file), "")
    end

    # code is a String
    def save_code(code = CodeEditor.instance.code)
      if inflated?
        @buffer+= "___CODE___?#{project_path}#{project_name}.rb\n"
        File.write("#{project_path}#{project_name}.rb", code)
        puts "Saved code to #{project_path}#{project_name}.rb"
      else
        @buffer+= "___CODE___\n"
      end
      @buffer+= code
      # @buffer+="\n" # CodeEditor always has this newline
    end

    # sheet is a Gosu::Image
    def save_spritesheet(sheet = SpriteEditor.instance.spritesheet)

      if inflated?
        @buffer+= "___SPRITES___?#{project_path}#{project_name}.png\n"
        sheet.save("#{project_path}#{project_name}.png")
        puts "Saved spritesheet to #{project_path}#{project_name}.png"
      else
        @buffer+= "___SPRITES___\n"
      end

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

      identify_mode(string)

      load_code(string)
      load_spritesheet(string)
      load_levels(string)
    end

    def identify_mode(string)
      if string.lines.size > 0 && string.lines.first.include?("# inflated")
        @mode = :inflated
      else
        @mode = :compact
      end
    end

    def load_code(string)
      buffer = ""
      in_code= false
      string.each_line do |line|
        if line.start_with?("___CODE___")
          if line.strip.include?("?") && inflated?
            # load from file
            puts "Loading code from: #{line.strip.split("?").last}"
            buffer = File.read(line.strip.split("?").last)
            break
          end
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
          if line.strip.include?("?") && inflated?
            # load from file
            puts "Loading spritesheet from: #{line.strip.split("?").last}"
            image  = Gosu::Image.new(line.strip.split("?").last, retro: true)
            buffer = image.to_blob
            width, height = image.width, image.height
            break
          end
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
        if inflated?
          stream = buffer
        else
          stream = buffer.scan(/../).map { |x| x.hex }.pack('c*')
        end
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
          # if line.strip.start_with?("__LEVELS___?")
          #   # load from file
          #   puts "Loading level data from: #{line.strip.split("?").last}"

          #   break
          # end
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