raise "Only require \"author_engine/opal\" with Opal!" unless RUBY_ENGINE == "opal"

require_relative "game/opal/parts/common"
require_relative "game/opal/parts/colors"
require_relative "game/opal/parts/graphics"
require_relative "game/opal/parts/input"

require_relative "game/game"
require_relative "game/opal/game_runner"