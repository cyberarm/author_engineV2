require "gosu"
require "coderay"

require_relative "lib/game/parts/common"
require_relative "lib/game/parts/graphics"
require_relative "lib/game/parts/colors"
require_relative "lib/game/parts/input"

require_relative "lib/window"
require_relative "lib/support"
require_relative "lib/container"
require_relative "lib/view"
require_relative "lib/button"
require_relative "lib/text"
require_relative "lib/sprite"
require_relative "lib/sprite_picker"
require_relative "lib/palette"
require_relative "lib/image"
require_relative "lib/save_file"

require_relative "lib/game/game"

require_relative "lib/code_editor/cursor"
require_relative "lib/code_editor/highlighting"

require_relative "lib/containers/editor"
require_relative "lib/containers/loader"

require_relative "lib/views/play_viewer"
require_relative "lib/views/sprite_editor"
require_relative "lib/views/level_editor"
require_relative "lib/views/code_editor"

AuthorEngine::Window.new.show