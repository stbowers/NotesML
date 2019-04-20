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

    val COLOR_DEFAULT = 1
    val COLOR_INVERTED = 2

    (* Create a window from a raw curses window
     *)
    fun fromScr(curses_win) = let
        val width = Curses.COLS()
        val height = Curses.LINES()
        val _ = Curses.clear()
        val _ = Curses.curs_set(0)
        val _ = Curses.init_pair(COLOR_DEFAULT, Curses.COLOR_WHITE, Curses.COLOR_BLACK)
        val _ = Curses.init_pair(COLOR_INVERTED, Curses.COLOR_BLACK, Curses.COLOR_WHITE)
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

    fun print_header(win: t_window ref, msg: string) = let
        val padding = (#width (!win)) - ((String.size msg) - 6)
        val line = StringCvt.padRight #"=" padding ("===|" ^ msg ^ "|")
    in
        Curses.attron(Curses.COLOR_PAIR(COLOR_DEFAULT));
        Curses.mvaddstr(0, 0, line);
        Curses.attroff(Curses.COLOR_PAIR(COLOR_DEFAULT))
    end

    fun render(win: t_window ref, app_data: AppData.t_data ref) = let
    in
        Curses.erase();
        print_header(win, "Hello!");
        Curses.refresh();
        ()
    end
end