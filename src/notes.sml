structure Application =
struct
    fun has_ch([], ch) = false
        |has_ch((Event.Input xh)::xt, ch) =
            if xh = (MLRep.Signed.fromInt (Char.ord ch)) then true
            else has_ch(xt, ch)
        |has_ch(xh::xt, ch) = has_ch(xt, ch)

    fun run(stdscr, (prog_name, args)) = let
        val app_data = ref AppData.default
        val window = ref (Window.fromScr(stdscr))
        fun run_recursive(app_data, event_queue) = let
            val _ = Window.render(window, app_data)
            val polled_events = Window.poll_events(window, true)
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