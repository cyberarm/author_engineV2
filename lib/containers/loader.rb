class AuthorEngine
  class Loader < Container
    Project = Struct.new(:name, :block)
    def setup
      @root_directory = "#{Dir.home}/AuthorEngineProjects"
      Dir.mkdir(@root_directory) unless File.exists?(@root_directory)

      @list = []
      @files = Dir.glob(@root_directory+"/*.authorengine")
      @font = Gosu::Font.new((6 * window.square_scale).floor, name: AuthorEngine::Text::FONT_DEFAULT)

      @files.each do |file|
        @list << Project.new(file, proc {load(folder)})
      end

      @index = ((@list.size)/2.0).round
      @list.rotate!(@index)
      @height = (@list.size-1)*@font.height

      @last_index = @index

      @new_button = Button.new(label: "New Project", color: dark_blue)
    end

    def load(filename)
      p filename
      window.container = Editor.new
      window.container.setup
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, window.darken(dark_gray, 50))

      Gosu.draw_rect(@new_button.x, @new_button.y, window.width, @new_button.height, window.lighten(black))
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
      case id
      when Gosu::KbUp
        # @list.rotate!(-1)
        # @index-=1
        # @index = (@index % @list.size-1)*-1
        # p @index
      when Gosu::KbDown
        @list.rotate!(1)
        @index+=1
        @index = @index % @list.size-1
      when Gosu::KbEnter, Gosu::KbReturn
        @list[@index].block.call if @list[@index]&.block
      end
    end
  end
end