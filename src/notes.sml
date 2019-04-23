structure Application =
struct
    val ONLY_UPDATE_ON_USER_INPUT = true

    fun run(stdscr, (prog_name, args)) = let
        val app_data = ref (AppData.default())
        val window = ref (Window.fromScr(stdscr))
        fun run_recursive(app_data, event_queue) = let
            val _ = Window.render(window, app_data)
            val polled_events = Window.poll_events(window, ONLY_UPDATE_ON_USER_INPUT)
            val produced_events = AppData.handle_events(app_data, event_queue @ polled_events)
        in
            if List.exists (fn(x) => Event.isQuit x) (produced_events) then 0
            else run_recursive(app_data, produced_events)
        end
    in
        run_recursive(app_data, [])
    end

    fun main(prog_name, args) = (Curses.wrap run)(prog_name, args)
end