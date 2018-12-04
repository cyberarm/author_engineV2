class AuthorEngine
  class CLI
    def initialize
      if ARGV[0] && ARGV[0] == "export"
        if ARGV[1] && ARGV[1].end_with?(".authorengine")
          require "author_engine/opal"
          AuthorEngine::OpalExporter.new(project_file: ARGV[1])
        else
          puts "author_engine export project [exported_name]"
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