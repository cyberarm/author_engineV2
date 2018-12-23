class AuthorEngine
  module TouchHandler
    def touch_handler_setup
      @current_touches = {}
    end

    def copy_touch(touch)
      {x: `touch.pageX`, y: `touch.pageY`}
    end

    def handle_touch_start(event)
      `#{event}.preventDefault()`
      touches = `#{event}.changedTouches`
      `for (var i = 0; i < #{touches}.length; i++) {
        #{@current_touches[`touches[i].identifier`] = copy_touch(`touches[i]`)}
      }`

      puts @current_touches
    end

    def handle_touch_move(event)
      `#{event}.preventDefault()`

      touches = `#{event}.changedTouches`
      `for (var i = 0; i < #{touches}.length; i++) {
        #{@current_touches[`touches[i].identifier`] = copy_touch(`touches[i]`)}
      }`

      puts @current_touches
    end

    def handle_touch_cancel(event)
      handle_touch_end(event)

      touches = `#{event}.changedTouches`
      `for (var i = 0; i < #{touches}.length; i++) {
        #{@current_touches.delete(`touches[i].identifier`)}
      }`

      puts @current_touches
    end

    def handle_touch_end(event)
      `#{event}.preventDefault()`

      touches = `#{event}.changedTouches`
      `for (var i = 0; i < #{touches}.length; i++) {
        #{@current_touches.delete(`touches[i].identifier`)}
      }`

      puts @current_touches
    end
  end
end