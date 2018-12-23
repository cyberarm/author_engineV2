raise "Only require \"author_engine/opal\" with Opal!" unless RUBY_ENGINE == "opal"

require_relative "game/common/parts/common"
require_relative "game/common/parts/collision_detection"
require_relative "game/common/parts/colors"

require_relative "game/opal/parts/graphics"
require_relative "game/opal/parts/input"

require_relative "collision_detection/collision_detection"
require_relative "sprite"

require_relative "game/game"
require_relative "save_file"
require_relative "game/opal/touch_handler"
require_relative "game/opal/touch_button"
require_relative "game/opal/game_runner"