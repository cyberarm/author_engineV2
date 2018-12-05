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
}
      }
    end

    def project
      %{
var projectString = `#{File.open(@project_file).read}`;
      }
    end

    def game_runtime
      program = %{
require "opal"
require "opal-parser"
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

      builder = Opal::Builder.new
      base_path = File.expand_path("../../../..", __FILE__)
      builder.append_paths("#{base_path}")

      puts "Transpiling to JavaScript using Opal..."


      builder.build("opal")
      builder.build("opal-parser")
      builder.build_require("author_engine/opal")

      builder.build_str(program, "(inline)").to_s
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
    <canvas id="canvas">
      <h1>You're Browser Does Not Support HTML5 Canvas!</h1>
    </canvas>

    <script src="application.js"></script>
  </body>
</html>
      }
    end

    def export
      template
    end

    def save(string)
      filename  = File.basename(@project_file)
      directory = File.expand_path(@project_file.sub(filename, ''))
      name      = filename.sub(".authorengine", "")

      export_path = "#{directory}/#{name}"
      unless File.exists?(export_path)
        Dir.mkdir(export_path)
        unless File.exists?("#{export_path}/fonts")
          Dir.mkdir("#{export_path}/fonts")
        end
      end

      puts "Saving to \"#{export_path}\""
      File.open("#{export_path}/#{name}.html", "w") do |file|
        file.write(string)
      end

      File.open("#{export_path}/application.js", "w") do |file|
        file.write(project)
        file.write("\n\n\n")
        file.write(game_runtime)
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