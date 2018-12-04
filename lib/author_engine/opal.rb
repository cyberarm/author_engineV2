require "opal"
require "opal-parser"

require_relative "game/opal/common"
require_relative "game/opal/colors"
require_relative "game/opal/graphics"
require_relative "game/opal/input"

require_relative "game/game"
require_relative "game/opal/game_runner"

unless RUBY_ENGINE == "opal"
  require_relative "game/opal/exporter"
end