(* Lightweight wrapper arround the native curses functions *)
structure Curses = struct
    (* ===== Types ===== *)
    type WINDOW = C.voidptr

    (* ===== Constants ===== *)
    val ERR = MLRep.Signed.fromInt ~1

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

    (* ===== Output functions ===== *)
    fun addch(out: char) = F_addch.f(MLRep.Signed.fromInt (Char.ord out))
    fun printw(out: string) = F_printw.f(ZString.dupML out)
    fun mvprintw(y: int, x: int, out: string) = F_mvprintw.f(MLRep.Signed.fromInt y, MLRep.Signed.fromInt x, ZString.dupML out)

    (* ===== Input functions ===== *)
    fun getch() = F_getch.f()

    (* ===== Helper functions ===== *)
    (* Wraps the supplied function so that curses is set up before calling the function
     * and is cleaned up before returning. If an uncaught exception occurs while executing 
     * the wrapped function, the terminal will be returned to a sane state before 
     * propagating the exception
     *)
    fun wrap(func: WINDOW * 'a -> 'b): 'a -> 'b = let
        val stdscr = initscr()
        val _ = cbreak()
        val _ = noecho()
        val _ = keypad(stdscr, true)
    in
        fn (args: 'a) => let
            val ret = func(stdscr, args)
            val _ = keypad(stdscr, false)
            val _ = echo()
            val _ = nocbreak()
            val _ = endwin()
        in
            ret
        end
        handle e =>
        let
            val _ = keypad(stdscr, false)
            val _ = echo()
            val _ = nocbreak()
            val _ = endwin()
        in
            raise e
        end
    end
end