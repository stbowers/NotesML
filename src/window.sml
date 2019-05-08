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
    val COLOR_CONTENT_CURSOR = 4

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
        val _ = Curses.init_pair(COLOR_CONTENT_CURSOR, Curses.COLOR_CYAN, Curses.COLOR_WHITE)
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

    fun print_header(win: t_window ref, msg: string, attrs) = let
        val line = StringCvt.padRight #"=" (!(#width (!win))) ("===|" ^ msg ^ "|")
    in
        Curses.attron(attrs);
        Curses.mvaddstr(0, 0, line);
        Curses.attroff(attrs)
    end

    (* Prints the given string inside of the specified box *)
    fun print_content(win: t_window ref, content: string, begin_x: int, begin_y:
      int, width: int, height: int, cursor_line: int, cursor_x: int,
      default_attrs: int, cursor_line_attrs: int, cursor_char_attrs: int) = let
          fun print_line(line, y, softline, softx) = let
              val line_attrs = if softline = cursor_line then cursor_line_attrs
                        else default_attrs
              val (current_line, next_line) =
                  if String.size line > width then (
                      String.extract(line, 0, SOME width),
                      SOME (String.extract(line, width, NONE))
                  )
                  else (
                      StringCvt.padRight #" " width line,
                      NONE
                  )
              val (line_left, line_cursor, line_right) =
                  if softline = cursor_line andalso cursor_x >= softx andalso
                  cursor_x < softx + width then (
                      String.substring(current_line, 0, cursor_x - softx),
                      String.substring(current_line, cursor_x - softx, 1),
                      String.extract(current_line, cursor_x - softx + 1, NONE)
                  )
                  else (current_line, "", "")
          in
              Curses.attron(line_attrs);
              Curses.mvaddstr(y, begin_x, line_left);
              Curses.attroff(line_attrs);
              Curses.attron(cursor_char_attrs);
              Curses.mvaddstr(y, begin_x + (String.size line_left), line_cursor);
              Curses.attroff(cursor_char_attrs);
              Curses.attron(line_attrs);
              Curses.mvaddstr(y, begin_x + (String.size line_left) + (String.size line_cursor), line_right);
              Curses.attroff(line_attrs);
              case next_line of
                   SOME line => print_line(line, y + 1, softline, softx + width)
                  |NONE => y + 1
          end

          fun print_lines([], y, softline) = ()
              |print_lines(line::lines, y, softline) = let
                  val next_line = print_line(line, y, softline, 0)
              in
                  print_lines(lines, next_line, softline + 1)
              end
        in
            print_lines(String.fields (fn ch => ch = #"\n") content, begin_y, 0)
        end

    fun render(win: t_window ref, app_data: AppData.t_data ref) = let
        val mode = AppData.get_mode app_data
        val debug_info = "f=" ^ Int.toString (!(#frame (!win))) ^ ",m=" ^ Int.toString(mode)
        val header_msg = "NotesML " ^ AppData.get_version app_data ^ " {" ^ debug_info ^ "}"

        val content_begin_x = !(#browser_width (!win)) + 1
        val content_begin_y = 1
        val content_width = !(#content_width (!win))
        val content_height = !(#height (!win)) - 1
        val content_cursor_line = AppData.get_content_cursor_line app_data
        val content_cursor_x = AppData.get_content_cursor_x app_data
        val content_default_attrs =
            if mode = 0 then Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_DEFAULT), Curses.A_DIM])
            else Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_CONTENT), Curses.A_BOLD])
        val content_cursor_line_attrs =
            if mode = 0 then Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_DEFAULT), Curses.A_DIM])
            else Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_CONTENT), Curses.A_UNDERLINE])
        val content_cursor_char_attrs =
            if mode = 0 then Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_DEFAULT), Curses.A_DIM])
            else Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_CONTENT_CURSOR), Curses.A_BOLD])
        val browser_default_attrs =
            if mode = 0 then Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_DEFAULT), Curses.A_BOLD])
            else Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_DEFAULT), Curses.A_DIM])
        val browser_selected_attrs =
            if mode = 0 then Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_INVERTED)])
            else Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_INVERTED), Curses.A_DIM])
        val split_attrs = Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_DEFAULT), Curses.A_BOLD])
        val header_attrs = Curses.combine_attrs([Curses.COLOR_PAIR(COLOR_DEFAULT), Curses.A_BOLD])

        fun print_notes([], index) = ()
            |print_notes(nh::nt, index) = let
                val attrs = if index = (AppData.get_selected app_data) then browser_selected_attrs else browser_default_attrs
                val name_str = StringCvt.padRight #" " (!(#browser_width (!win))) nh
            in
                Curses.attron(attrs);
                Curses.mvaddstr(1 + index, 0, name_str);
                Curses.attroff(attrs);
                print_notes(nt, index + 1)
            end

        fun print_split(line) =
            if line = !(#height (!win)) then ()
            else (
                Curses.attron(split_attrs);
                Curses.mvaddch(line, !(#browser_width (!win)), #"|");
                Curses.attroff(split_attrs);
                print_split(line + 1)
            )
    in
        (#frame (!win)) := !(#frame (!win)) + 1;
        Curses.erase();

        print_header(win, header_msg, header_attrs);
        print_notes(AppData.get_notes app_data, 0);
        print_split(1);

        print_content(win, AppData.get_note_content(app_data, AppData.get_selected app_data), content_begin_x, content_begin_y, content_width, content_height,
            content_cursor_line, content_cursor_x, content_default_attrs, content_cursor_line_attrs,
            content_cursor_char_attrs);

        Curses.refresh();

        ()
    end
end
