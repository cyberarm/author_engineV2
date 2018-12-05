require "opal"

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

    def opal_runtime
      program = %{
require "opal"
require "opal-parser"
require "author_engine/opal"

AuthorEngine::GameRunner.new(`projectString`).show
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

    <script>
      #{project}

      #{opal_runtime}
    </script>
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

      puts "Saving to \"#{directory}/#{name}.html\""
      File.open("#{directory}/#{name}.html", "w") do |file|
        file.write(string)
      end
    end
  end
end