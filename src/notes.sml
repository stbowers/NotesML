structure Application =
struct
    fun has_ch([], ch) = false
        |has_ch((Event.Input xh)::xt, ch) =
            if xh = (MLRep.Signed.fromInt (Char.ord ch)) then true
            else has_ch(xt, ch)
        |has_ch(xh::xt, ch) = has_ch(xt, ch)

    fun run(stdscr, (prog_name, args)) = let
        val app_data = ref AppData.default
        val run = ref true
        val events = ref []
        val return_code = ref 0
    in
        while !run do
        (
            (* First render the application, so the user has the most up-to-date view before sending input to the program *)
            Window.render(app_data);

            (* Poll the window for new events, adding them to the list of events produced in the last iteration *)
            events := !events @ Window.poll_events(stdscr, true);

            (* Process the events *)
            events := AppData.handle_events(app_data, !events);

            (* *)
            if List.exists (fn(x) => Event.isQuit x) (!events) then (run := false) else ()
        );

        !return_code
    end

    fun main(prog_name, args) = (Curses.wrap run)(prog_name, args)
end