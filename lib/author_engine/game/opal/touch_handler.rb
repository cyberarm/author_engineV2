class AuthorEngine
  module TouchHandler
    def touch_handler_setup
      @current_touches = []
    end

    def handle_touch_start(event)
    end

    def handle_touch_move(event)
    end

    def handle_touch_cancel(event)
      handle_touch_end(event)
    end

    def handle_touch_end(event)
    end
  end