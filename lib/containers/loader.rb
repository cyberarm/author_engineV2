class AuthorEngine
  class Loader < Container
    Project = Struct.new(:name, :block)
    def setup
      @root_directory = Dir.pwd#"#{Dir.home}/AuthorEngineProjects"
      Dir.mkdir(@root_directory) unless File.exists?(@root_directory)

      @list = []
      @files = Dir.glob(@root_directory+"/*.authorengine")
      @font = Gosu::Font.new((6 * window.square_scale).floor, name: AuthorEngine::Text::FONT_DEFAULT)

      @files.each do |file|
        @list << Project.new(file, proc {load(file)})
      end

      @index = ((@list.size)/2.0).floor
      @list.rotate!(@index)
      @height = (@list.size-1)*@font.height

      @last_index = @index
      @entering_name = false

      @header_color = Gosu::Color.rgba(dark_green.red, dark_green.green, dark_green.blue, 100)
      @new_button   = Button.new(label: "New Project", color: @header_color) do
        window.text_input = Gosu::TextInput.new
        @entering_name = true
      end
      @new_button.x = window.width - @new_button.width
    end

    def load(filename)
      p filename
      savefile = SaveFile.new(filename)
      window.container = Editor.new(savefile)
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, window.darken(dark_gray, 50))

      if @entering_name
        draw_inputter
      else
        draw_loader
      end
    end

    def draw_inputter
      x = window.width/2 - @font.text_width(window.text_input.text+".authorengine")/2
      y = window.height/2 - @font.height/2
      @font.draw_text(window.text_input.text+".authorengine", x, y, 0)
    end

    def draw_loader
      Gosu.draw_rect(0, @new_button.y, window.width, @new_button.height, @header_color)
      @font.draw_text("AuthorEngine", 1*window.square_scale,@font.height/2,0)
      @new_button.draw
      @font.draw_text(@list[@index].name, 0, 0, 0) if @list[@index]

      Gosu.clip_to(0, @font.height*2, window.width, window.height-(@font.height*4)) do
        y = (window.height/2-@font.height) - (@height/2)

        @list.each_with_index do |project, index|
          label = project.name.sub(@root_directory+"/", '')
          x = window.width/2 - @font.text_width(label)/2
          if project == @list[@index]
            Gosu.draw_rect(0, y, window.width, @font.height, red)
          end
          @font.draw_text(label, x, y, 0)
          y+=@font.height
        end
      end
    end

    def update
    end

    def button_up(id)
      @new_button.button_up(id)

      case id
      when Gosu::KbUp
        # @list.rotate!(-1)
        # @index-=1
        # @index = (@index % @list.size-1)*-1
        # p @index
      when Gosu::KbDown
        @list.rotate!(1)
        @index+=1
        @index = 0 if @list.size == 0
        @index = @index % @list.size-1 if @list.size != 0
      when Gosu::KbEnter, Gosu::KbReturn
        if @entering_name
          SaveFile.create(window.text_input.text.strip+".authorengine")
          load(window.text_input.text.strip+".authorengine")
        else
          @list[@index].block.call if @list[@index]&.block
        end
      end
    end
  end
end