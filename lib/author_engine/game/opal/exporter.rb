require "opal"
require "fileutils"
require_relative "../../version"

class AuthorEngine
  class OpalExporter
    def initialize(project_file:)
      @project_file = project_file

      save(export)
    end

    def project_name
      name = File.basename(@project_file, ".authorengine")
      return name.split("_").map {|n| n.capitalize}.join(" ")
    end

    # Rebuild author_engine runtime if it doesn't exist or if its out of date
    def build_authorengine?
      authorengine_runtime = "#{export_directory}/js/author_engine.js"

      if File.exists?(authorengine_runtime)
        file = File.open(authorengine_runtime)
        version = file.first.gsub("/", "").strip
        file.close

        AuthorEngine::VERSION != version
      else
        true
      end
    end

    def stylesheet
      %{
@font-face { font-family: Connection; src: url('fonts/Connection.otf'); }
@font-face { font-family: ConnectionBold; src: url('fonts/ConnectionBold.otf'); }

body {
  margin: 0;
  padding: 0;
  background: #222;
}
#canvas {
  display: block;
  margin: 0 auto;
  cursor: none;
}
#loading {
  font-family: Connection, sans-serif;
  color: white;
  text-align: center;

  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  width: 50%;
  height: 30%;
  margin: auto;
}
      }
    end

    def project
      file = File.read(@project_file)

      %{
var projectString = `#{file}`;
      }
    end

    def author_engine_runtime
      program = %{
require "author_engine/opal"

`var callback = function(){
  \#{AuthorEngine::GameRunner.new(`projectString`).show}
};

if (
    document.readyState === "complete" ||
    (document.readyState !== "loading" && !document.documentElement.doScroll)
) {
  callback();
} else {
  document.addEventListener("DOMContentLoaded", callback);
}`
      }

      puts "Transpiling to JavaScript using Opal..."

      author_engine_builder = nil
      if build_authorengine?
        puts "  Building AuthorEngine runtime..."

        author_engine_builder = Opal::Builder.new
        base_path = File.expand_path("../../../..", __FILE__)
        author_engine_builder.append_paths("#{base_path}")

        author_engine_builder.build_require("author_engine/opal")
      else
        puts "  Skipping AuthorEngine runtime. Already exists and up to date (v#{AuthorEngine::VERSION})..."
      end

      author_engine_js = nil
      if author_engine_builder
        author_engine_js = author_engine_builder.build_str(program, "(inline)").to_s
      end

      return author_engine_js
    end

    def template
      %{
<!doctype html5>
<html>
  <head>
    <meta content="width=device-width, initial-scale=1" name="viewport" />
    <meta charset="utf-8" />
    <title>#{project_name} | AuthorEngine</title>
  </head>
  <style>
    #{stylesheet}
  </style>
  <body>
    <h1 id="loading">Loading...</h1>
    <canvas id="canvas">
      <h1>Your Browser Does Not Support HTML5 Canvas!</h1>
    </canvas>

    <script src="game.js"></script>
    <script>
      // Add a small delay before loading application in order to finish loading page and show "Loading..."
      window.setTimeout(function() {
        console.log("Loading Opal...");

        var opal = document.createElement('script');
        opal.onload = function() {
          console.log("Loading Opal Parser...");

          var opal_parser = document.createElement('script');
          opal_parser.onload = function() {
            Opal.load('opal-parser');

            console.log("Loading AuthorEngine runtime...");

            var author_engine_runtime = document.createElement('script');
            author_engine_runtime.src = "js/author_engine.js";

            document.head.appendChild(author_engine_runtime);
          }
          opal_parser.src = "js/opal-parser.min.js";

          document.head.appendChild(opal_parser);
        }
        opal.src = "js/opal.min.js";

        document.head.appendChild(opal);
      }, 500);
    </script>
  </body>
</html>
      }
    end

    def export
      template
    end

    def export_directory
      filename  = File.basename(@project_file)
      directory = File.expand_path(@project_file.sub(filename, ''))
      name      = filename.sub(".authorengine", "")

      return "#{directory}/#{name}"
    end

    def save(string)
      filename  = File.basename(@project_file)
      directory = File.expand_path(@project_file.sub(filename, ''))
      name      = filename.sub(".authorengine", "")
      export_path = "#{directory}/#{name}"

      unless File.exists?(export_path)
        Dir.mkdir(export_path)
      end
      unless File.exists?("#{export_path}/fonts")
        Dir.mkdir("#{export_path}/fonts")
      end
      unless File.exists?("#{export_path}/js")
        Dir.mkdir("#{export_path}/js")
      end

      puts "Saving to \"#{export_path}\""
      File.open("#{export_path}/#{name}.html", "w") do |file|
        file.write(string)
      end

      local = File.expand_path("../../../../../vendor", __FILE__)
      FileUtils.cp(["#{local}/opal.min.js", "#{local}/opal.min.js"], "#{export_directory}/js")

      puts "  Building game..."
      File.open("#{export_path}/game.js", "w") do |file|
        file.write(project)
      end

      if runtime = author_engine_runtime
        File.open("#{export_path}/js/author_engine.js", "w") do |file|
          file.write("// #{AuthorEngine::VERSION}\n")
          file.write(runtime)
        end
      end

      fonts_path = "#{File.expand_path("../../../../../", __FILE__)}/assets/fonts"
      font_files = Dir.glob("#{fonts_path}/*")
      font_files.each do |file|
        FileUtils.cp(file, "#{export_path}/fonts/#{File.basename(file)}")
      end

      puts "Saved."
    end
  end
end