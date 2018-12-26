class AuthorEngine
  class CLI
    def initialize
      if ARGV[0] && ARGV[0] == "export"
        if ARGV[1] && ARGV[1].end_with?(".authorengine")
          require "author_engine/game/opal/exporter"

          AuthorEngine::OpalExporter.new(project_file: ARGV[1])
        else
          puts "author_engine export project [exported_name]"
        end

      elsif ARGV[0] && ARGV[0] == "inflate"
        if ARGV[1] && ARGV[1].end_with?(".authorengine")
          if File.exists?(ARGV[1])
            savefile = SaveFile.new(ARGV[1])
            savefile.inflate!
            puts "Inflated #{ARGV[1]}"
          end
        end

      elsif ARGV[0] && ARGV[0].end_with?(".authorengine")
        # The Loader Container handles loading projects
        AuthorEngine::Window.new.show
      else
        AuthorEngine::Window.new.show
      end
    end
  end
end