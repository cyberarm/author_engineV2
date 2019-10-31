require "opal"
require "fileutils"

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

    # Rebuild opal runtime of it doesn't exist or if its out of date
    def build_opal?
      opal_runtime = "#{export_directory}/js/runtime.js"

      if File.exists?(opal_runtime)
        file = File.open(opal_runtime)
        version = file.first.gsub("/", "").strip
        file.close

        Opal::VERSION != version
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
  // cursor: none;
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

    def game_runtime
      program = %{
# require "opal"
# require "opal-parser"
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

      opal_builder = nil
      if build_opal?
        puts "  Building Opal runtime..."

        opal_builder = Opal::Builder.new
        opal_builder.build("opal")
        opal_builder.build("opal-parser")
      else
        puts "  Skipping Opal runtime. Already exists as v#{Opal::VERSION}..."
      end

      puts "  Building AuthorEngine runtime with project..."
      game_builder = Opal::Builder.new
      base_path = File.expand_path("../../../..", __FILE__)
      game_builder.append_paths("#{base_path}")

      game_builder.build_require("author_engine/opal")

      opal_builder_js  = nil
      if opal_builder
        opal_runtime_js = opal_builder.build_str("", "(inline)").to_s
      end

      author_engine_js = game_builder.build_str(program, "(inline)").to_s

      return {opal_runtime: opal_runtime_js, author_engine_runtime: author_engine_js}
    end

    def template
      %{
<!doctype html5>
<html>
  <head>
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
        console.log("Loading Opal runtime...");

        var opal_runtime = document.createElement('script');
        opal_runtime.onload = function() {
          console.log("Loading AuthorEngine runtime...");

          var author_engine_runtime = document.createElement('script');
          author_engine_runtime.src = "js/author_engine.js";
          document.head.appendChild(author_engine_runtime);
        }
        opal_runtime.src = "js/runtime.js";

        document.head.appendChild(opal_runtime);
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

      hash = game_runtime
      if hash[:opal_runtime]
        File.open("#{export_path}/js/runtime.js", "w") do |file|
          file.write("// #{Opal::VERSION}\n")
          file.write(hash[:opal_runtime])
        end
      end

      File.open("#{export_path}/game.js", "w") do |file|
        file.write(project)
      end

      File.open("#{export_path}/js/author_engine.js", "w") do |file|
        file.write(hash[:author_engine_runtime])
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