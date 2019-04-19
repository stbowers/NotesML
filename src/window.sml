structure Window = struct
    type event_type = MLRep.Signed.int

    (* Poll events from curses
     * Returns a list of chars (from successive calls to getch) that represent the user input to
     * the program since the last call to poll_events. If block is true, this function will wait
     * to return until there is at least one event, so the application will not be busy processing
     * when the user has not entered anything.
     *)
    fun poll_events(win: Curses.WINDOW, block: bool): Event.event list = let
        val _ = Curses.nodelay(win, not block)
        fun get_events(nil) = let
            val event = Curses.getch()
            val _ = Curses.nodelay(win, true)
        in
            if event = Curses.ERR then nil
            else get_events([Event.fromChar (event)])
        end
            |get_events(events) = let
            val event = Curses.getch()
        in
            if event = Curses.ERR then events
            else get_events(events @ [Event.fromChar (event)])
        end
    in
        get_events(nil)
    end

    fun render(app_data: AppData.data_type ref) = let
        val _ = Curses.mvprintw(0, 0, "Hello, World!")
        val _ = Curses.refresh()
    in
        0
    end
end