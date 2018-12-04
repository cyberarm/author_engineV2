require "erb"

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
      %x{
        var projectString = "#{File.open(@project_file).read}";
      }
    end

    def opal_runtime
      program = %{
        require "author_engine/opal"

        AuthorEngine::GameRunner.new(`projectString`).show
      }

      Opal.compile(program)
    end

    def template
      %{
        <!doctype html5>
        <html>
          <head>
            <meta charset="utf-8" />
            <title>#{project_name} | AuthorEngine</title
          </head>
          <style>
            #{stylesheet}
          </style>
          <body>
            <canvas id="canvas">
              <h1>You're Browser Does Not Support HTML5 Canvas!</h1>
            </canvas>
          </body>
          <script>
            #{project}

            #{opal_runtime}
          </script>
        </html>
      }
    end

    def export
      ERB.new(template).result(binding)
    end

    def save(string)
      filename  = File.basename(@project_file)
      directory = File.expand_path(@project_file.sub(filename, ''))
      name      = filename.sub(".authorengine", "")

      File.open("#{directory}/#{name}.html") do |file|
        file.write(string)
      end
    end
  end
end