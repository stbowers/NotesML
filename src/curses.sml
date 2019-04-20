(* Lightweight wrapper arround the native curses functions *)
structure Curses = struct
    (* ===== Types ===== *)
    type WINDOW = C.voidptr

    (* ===== Constants ===== *)
    val ERR = MLRep.Signed.fromInt ~1
    val COLOR_BLACK = 0
    val COLOR_RED = 1
    val COLOR_GREEN = 2
    val COLOR_YELLOW = 3
    val COLOR_BLUE = 4
    val COLOR_MAGENTA = 5
    val COLOR_CYAN = 6
    val COLOR_WHITE = 7

    (* ===== External variables ===== *)
    fun COLS() = MLRep.Signed.toInt(C.Get.sint(G_COLS.obj()))
    fun LINES() = MLRep.Signed.toInt(C.Get.sint(G_LINES.obj()))

    (* ===== Helper functions ===== *)
    fun bool_to_int(b: bool) = Word32.fromInt(if b then 1 else 0)
    fun int_to_bool(i: Word32.word) = not (Word32.toInt i = 0)

    (* ===== Control functions ===== *)
    fun initscr() : WINDOW = F_initscr.f()

    fun endwin() = F_endwin.f()
    fun refresh() = F_refresh.f()

    fun cbreak() = F_cbreak.f()
    fun nocbreak() = F_nocbreak.f()
    fun echo() = F_echo.f()
    fun noecho() = F_noecho.f()
    (* int halfdelay(int tenths); *)
    (* int intrflush(WINDOW *win, bool bf); *)
    fun keypad(window, bf: bool) =
    let
        val boolval = Word32.fromInt (if bf then 1 else 0)
    in
        F_keypad.f(window, boolval)
    end
    (* int meta(WINDOW *win, bool bf); *)
    fun nodelay(window, bf: bool) = let
        val boolval = Word32.fromInt (if bf then 1 else 0)
    in
        F_nodelay.f(window, boolval)
    end
    (* int raw(); *)
    (* int noraw(); *)
    (* void noqiflush(); *)
    (* void qiflush(); *)
    (* int notimeout(WINDOW *win, bool bf); *)
    (* void timeout(int delay); *)
    (* void wtimeout(WINDOW *win, int delay); *)
    (* int typeahead(int fd); *)

    fun curs_set(visibility) = F_curs_set.f(visibility)

    fun start_color() = F_start_color.f()
    fun has_colors() = int_to_bool(F_has_colors.f())
    fun can_change_color() = F_can_change_color.f()
    fun init_pair(pair: int, f: int, b: int) = let
        val c_pair = MLRep.Signed.fromInt pair
        val c_f = MLRep.Signed.fromInt f
        val c_b = MLRep.Signed.fromInt b
    in
        F_init_pair.f(c_pair, c_f, c_b)
    end
    fun init_color(color: int, r: int, g: int, b: int) = let
        val c_color = MLRep.Signed.fromInt color
        val c_r = MLRep.Signed.fromInt r
        val c_g = MLRep.Signed.fromInt g
        val c_b = MLRep.Signed.fromInt b
    in
        F_init_color.f(c_color, c_r, c_g, c_b)
    end

    fun use_default_colors() = F_use_default_colors.f()
    fun assume_default_colors(fg, bg) = F_assume_default_colors.f(fg, bg)

    fun getattrs(win) = MLRep.Signed.toInt(F_getattrs.f(win))
    fun getbegx(win) = MLRep.Signed.toInt(F_getbegx.f(win))
    fun getbegy(win) = MLRep.Signed.toInt(F_getbegx.f(win))
    fun getcurx(win) = MLRep.Signed.toInt(F_getbegx.f(win))
    fun getcury(win) = MLRep.Signed.toInt(F_getbegx.f(win))
    fun getmaxx(win) = MLRep.Signed.toInt(F_getbegx.f(win))
    fun getmaxy(win) = MLRep.Signed.toInt(F_getbegx.f(win))
    fun getparx(win) = MLRep.Signed.toInt(F_getbegx.f(win))
    fun getpary(win) = MLRep.Signed.toInt(F_getbegx.f(win))

    fun erase() = F_erase.f()
    fun werase(win) = F_werase.f(win)
    fun clear() = F_clear.f()
    fun wclear(win) = F_wclear.f(win)
    fun clrtobot() = F_clrtobot.f()
    fun wclrtobot(win) = F_wclrtobot.f(win)
    fun clrtoeol() = F_clrtoeol.f()
    fun wclrtoeol(win) = F_wclrtoeol.f(win)

    (* ===== Output functions ===== *)
    fun addch(out: char) = F_addch.f(MLRep.Signed.fromInt (Char.ord out))

    fun addstr(str: string) = F_addstr.f(ZString.dupML str)
    fun addnstr(str: string, n: int) = F_addnstr.f(ZString.dupML str, MLRep.Signed.fromInt n)
    fun waddstr(win, str: string) = F_waddstr.f(win, ZString.dupML str)
    fun waddnstr(win, str: string, n: int) = F_waddnstr.f(win, ZString.dupML str, MLRep.Signed.fromInt n)
    fun mvaddstr(y: int, x: int, str: string) = F_mvaddstr.f(MLRep.Signed.fromInt y, MLRep.Signed.fromInt x, ZString.dupML str)
    fun mvaddnstr(y: int, x: int, str: string, n: int) = F_mvaddnstr.f(MLRep.Signed.fromInt y, MLRep.Signed.fromInt x, ZString.dupML str, MLRep.Signed.fromInt n)
    fun mvwaddstr(win, y: int, x: int, str: string) = F_mvwaddstr.f(win, MLRep.Signed.fromInt y, MLRep.Signed.fromInt x, ZString.dupML str)
    fun mvwaddnstr(win, y: int, x: int, str: string, n: int) = F_mvwaddnstr.f(win, MLRep.Signed.fromInt y, MLRep.Signed.fromInt x, ZString.dupML str, MLRep.Signed.fromInt n)

    fun attr_get(attrs, pair, opts) = F_attr_get.f(attrs, pair, opts)
    fun wattr_get(win, attrs, pair, opts) = F_wattr_get.f(win, attrs, pair, opts)
    fun attr_set(attrs, pair, opts) = F_attr_set.f(attrs, pair, opts)
    fun wattr_set(win, attrs, pair, opts) = F_wattr_set.f(win, attrs, pair, opts)

    fun attr_off(attrs, opts) = F_attr_off.f(attrs, opts)
    fun wattr_off( win, attrs, opts) = F_wattr_off.f(win, attrs, opts)
    fun attr_on(attrs, opts) = F_attr_on.f(attrs, opts)
    fun wattr_on(win, attrs, opts) = F_wattr_on.f(win, attrs, opts)

    fun attroff(attrs) = F_attroff.f(attrs)
    fun wattroff(win, attrs) = F_wattroff.f(win, attrs)
    fun attron(attrs) = F_attron.f(attrs)
    fun wattron(win, attrs) = F_wattron.f(win, attrs)
    fun attrset(attrs) = F_attrset.f(attrs)
    fun wattrset(win, attrs) = F_wattrset.f(win, attrs)

    fun COLOR_PAIR(pair: int) = F_COLOR_PAIR.f(MLRep.Signed.fromInt pair)

    (* ===== Input functions ===== *)
    fun getch() = F_getch.f()

    (* ===== Helper functions ===== *)
    (* Wraps the supplied function so that curses is set up before calling the function
     * and is cleaned up before returning. If an uncaught exception occurs while executing 
     * the wrapped function, the terminal will be returned to a sane state before 
     * propagating the exception
     *)
    datatype 'b result = OK of 'b | ERROR of exn
    fun wrap(func: WINDOW * 'a -> 'b): 'a -> 'b = let

        val stdscr = initscr()
        val _ = if has_colors() then (start_color(); ()) else ()
        val _ = cbreak()
        val _ = noecho()
        val _ = keypad(stdscr, true)

        fun exit(ret: 'b result) = let
            val _ = keypad(stdscr, false)
            val _ = echo()
            val _ = nocbreak()
            val _ = endwin()
        in
            case ret of
                OK ret => ret
                |ERROR e => raise e
        end
    in
        fn (args: 'a) => let
            val ret = func(stdscr, args)
        in
            exit(OK ret)
        end
        handle e => exit(ERROR e)
    end
end