signature WINDOW = sig
    type t_window

    val fromScr: Curses.WINDOW -> t_window

    val poll_events: (t_window ref * bool) -> Event.event list
    val render: (t_window ref * AppData.t_data ref) -> unit
end

structure Window :> WINDOW = struct
    type t_window = {
        win: Curses.WINDOW,
        width: int,
        height: int
    }

    (* Create a window from a raw curses window
     *)
    fun fromScr(curses_win) = let
        val width = Curses.COLS()
        val height = Curses.LINES()
    in
        {
            win = curses_win,
            width = width,
            height = height
        }
    end

    (* Poll events from curses
     * Returns a list of chars (from successive calls to getch) that represent the user input to
     * the program since the last call to poll_events. If block is true, this function will wait
     * to return until there is at least one event, so the application will not be busy processing
     * when the user has not entered anything.
     *)
    fun poll_events(win: t_window ref, block: bool): Event.event list = let
        val _ = Curses.nodelay(#win (!win), not block)
        fun get_events(nil) = let
            val event = Curses.getch()
            val _ = Curses.nodelay(#win (!win), true)
        in
            if event = Curses.ERR then nil
            else get_events([Event.Input (event)])
        end
            |get_events(events) = let
            val event = Curses.getch()
        in
            if event = Curses.ERR then events
            else get_events(events @ [Event.Input (event)])
        end
    in
        get_events(nil)
    end

    fun render(win: t_window ref, app_data: AppData.t_data ref) = let
        val _ = Curses.mvprintw(0, 0, "Hello, World! i = " ^ Int.toString(AppData.get_i(!app_data)))
        val _ = Curses.mvprintw(1, 0, "Win: " ^ Int.toString(#width (!win)) ^ "x" ^ Int.toString(#height (!win)) )
        val _ = AppData.set_i(app_data)
        val _ = Curses.refresh()
    in
        ()
    end
end