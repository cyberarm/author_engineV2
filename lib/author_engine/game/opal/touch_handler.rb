class AuthorEngine
  module TouchHandler
    Touch = Struct.new(:x, :y)
    def touch_handler_setup
      @current_touches = {}
    end

    def copy_touch(touch)
      Touch.new(`touch.pageX`, `touch.pageY`)
    end

    def handle_touch_start(event)
      `#{event}.preventDefault()`

      touches = `#{event}.changedTouches`
      `for (var i = 0; i < #{touches}.length; i++) {
        #{@current_touches[`touches[i].identifier`] = copy_touch(`touches[i]`)}
      }`

      return nil
    end

    def handle_touch_move(event)
      `#{event}.preventDefault()`

      touches = `#{event}.changedTouches`
      `for (var i = 0; i < #{touches}.length; i++) {
        #{@current_touches[`touches[i].identifier`] = copy_touch(`touches[i]`)}
      }`

      return nil
    end

    def handle_touch_cancel(event)
      handle_touch_end(event)
    end

    def handle_touch_end(event)
      `#{event}.preventDefault()`

      touches = `#{event}.changedTouches`
      `for (var i = 0; i < #{touches}.length; i++) {
        #{@current_touches.delete(`touches[i].identifier`)}
      }`

      return nil
    end
  end
end