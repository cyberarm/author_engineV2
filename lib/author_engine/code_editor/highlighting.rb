class AuthorEngine
  class CodeEditor < View
    class Highlighting
      include AuthorEngine::Part::Colors

      def initialize
        @highlight_colors = {
          instance_variable: xml_color(green),
          keyword: xml_color(red),
          method: xml_color(yellow),
          ident: xml_color(yellow),
          comment: xml_color(dark_gray),
          constant: xml_color(orange),

          delimiter: xml_color(blue),
          content: xml_color(blue),
          integer: xml_color(blue),
          float: xml_color(blue),
          symbol: xml_color(blue),
        }

        @last_text = ""
      end

      def highlight(string:, text:)
        return unless @last_text != string
        @last_text = string

        buffer = ""

        tokens = CodeRay.scan(string, :ruby).tokens
        tokens.each_with_index do |token, index|
          buffer = "#{buffer}#{style(text: token, token: tokens[index+1])}" if token.is_a?(String)
        end

        text.message = buffer
      end

      def style(text:, token:)
        color = @highlight_colors.dig(token)
        if color
          return "<c=#{color}>#{text}</c>"
        else
          return text
        end
      end
    end
  end
end