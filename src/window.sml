structure Window = struct
    fun poll_events(win: Curses.WINDOW, block: bool) = let
        val _ = Curses.nodelay(win, not block)
        fun get_events(nil) = let
            val event = Curses.getch()
            val _ = Curses.nodelay(win, true)
        in
            if event = Curses.ERR then nil
            else get_events([event])
        end
            |get_events(events) = let
            val event = Curses.getch()
        in
            if event = Curses.ERR then events
            else get_events(events @ [event])
        end
    in
        get_events(nil)
    end
end