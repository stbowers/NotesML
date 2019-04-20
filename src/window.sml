signature WINDOW = sig
    type t_window

    val fromScr: Curses.WINDOW -> t_window

    val poll_events: (t_window ref * bool) -> Event.event list
    val render: (t_window ref * AppData.t_data ref) -> unit
end

structure Window :> WINDOW = struct
    type t_window = {
        win: Curses.WINDOW,
        width: int ref,
        height: int ref,
        browser_width: int ref,
        content_width: int ref,
        frame: int ref
    }

    val COLOR_DEFAULT = 1
    val COLOR_INVERTED = 2
    val COLOR_CONTENT = 3

    (* Create a window from a raw curses window
     *)
    fun fromScr(curses_win) = let
        val width = Curses.COLS()
        val height = Curses.LINES()
        val browser_width = Real.floor(0.25 * Real.fromInt width)
        val content_width = width - browser_width - 1

        val _ = Curses.clear()
        val _ = Curses.curs_set(0)
        val _ = Curses.init_pair(COLOR_DEFAULT, Curses.COLOR_WHITE, Curses.COLOR_BLACK)
        val _ = Curses.init_pair(COLOR_INVERTED, Curses.COLOR_BLACK, Curses.COLOR_WHITE)
        val _ = Curses.init_pair(COLOR_CONTENT, Curses.COLOR_CYAN, Curses.COLOR_BLACK)
    in
        {
            win = curses_win,
            width = ref width,
            height = ref height,
            browser_width = ref browser_width,
            content_width = ref content_width,
            frame = ref 0
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
        val line = StringCvt.padRight #"=" (!(#width (!win))) ("===|" ^ msg ^ "|")
    in
        Curses.attron(Curses.COLOR_PAIR(COLOR_DEFAULT));
        Curses.mvaddstr(0, 0, line);
        Curses.attroff(Curses.COLOR_PAIR(COLOR_DEFAULT))
    end

    (* Prints the given string inside of the specified box *)
    fun print_content(win: t_window ref, content: string, begin_x: int, begin_y: int, width: int, height: int, attrs: int) = let
        fun print_content_chars([], x, y) = ()
            |print_content_chars(ch::ct, x, y) = let
                val (x, y) = if x >= (begin_x + width) then (begin_x, y + 1)
                    else (x, y)
            in
                if y >= (begin_y + height) then ()
                else if ch = #"\n" then (
                    print_content_chars(ct, begin_x, y + 1)
                )
                else (
                    Curses.attron(attrs);
                    Curses.mvaddch(y, x, ch);
                    Curses.attroff(attrs);
                    print_content_chars(ct, x + 1, y)
                )
            end
    in
        print_content_chars(String.explode content, begin_x, begin_y)
    end

    fun render(win: t_window ref, app_data: AppData.t_data ref) = let
        val debug_info = "f=" ^ Int.toString (!(#frame (!win))) ^ ",m=" ^ Int.toString(AppData.get_mode app_data)
        fun print_notes(win: t_window ref, [], index, selected_index) = ()
            |print_notes(win: t_window ref, nh::nt, index, selected_index) = let
                val color = if index = selected_index then COLOR_INVERTED else COLOR_DEFAULT
                val name_str = StringCvt.padRight #" " (!(#browser_width (!win))) nh
            in
                Curses.attron(Curses.COLOR_PAIR(color));
                Curses.mvaddstr(1 + index, 0, name_str);
                Curses.attroff(Curses.COLOR_PAIR(color));
                print_notes(win, nt, index + 1, selected_index)
            end
        fun print_split(win: t_window ref, line) =
            if line = !(#height (!win)) then ()
            else (
                Curses.mvaddstr(line, !(#browser_width (!win)), "|");
                print_split(win, line + 1)
            )
        val content_begin_x = !(#browser_width (!win)) + 1
        val content_begin_y = 1
        val content_width = !(#content_width (!win))
        val content_height = !(#height (!win)) - 1
        val content_attrs = Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_CONTENT), Curses.A_BOLD])
    in
        (#frame (!win)) := !(#frame (!win)) + 1;
        Curses.erase();
        print_header(win, "NotesML " ^ AppData.get_version app_data ^ " {" ^ debug_info ^ "}");
        print_notes(win, AppData.get_notes app_data, 0, AppData.get_selected app_data);
        print_split(win, 1);
        print_content(win, AppData.get_note_content(app_data, AppData.get_selected app_data), content_begin_x, content_begin_y, content_width, content_height, content_attrs);
        Curses.refresh();
        ()
    end
end