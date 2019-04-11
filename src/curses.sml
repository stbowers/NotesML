(* Lightweight wrapper arround the native curses functions *)
structure Curses = struct
    (* ===== Constants ===== *)
    val ERR = ~1

    (* ===== Variables ===== *)
    val stdscr = C.Ptr.vNull

    (* ===== Control functions ===== *)
    fun initscr() = 
    let
        val stdscr = F_initscr.f()
    in
        stdscr
    end

    fun endwin() = F_endwin.f()
    fun refresh() = F_refresh.f()

    fun cbreak() = F_cbreak.f()
    fun nocbreak() = F_nocbreak.f()
    fun echo() = F_echo.f()
    fun noecho() = F_noecho.f()
    fun keypad(window, bf: bool) =
    let
        val boolval = Word32.fromInt (if bf then 1 else 0)
    in
        F_keypad.f(window, boolval)
    end

    fun curs_set(visibility) = F_curs_set.f(visibility)

    (* ===== Output functions ===== *)
    fun printw(out: string) = F_printw.f(ZString.dupML out)

    (* ===== Input functions ===== *)
    fun getch() = F_getch.f()

    (* ===== Helper functions ===== *)
    (* Wraps the supplied function so that curses is set up before calling the function
     * and is cleaned up before returning. If an uncaught exception occurs while executing 
     * the wrapped function, the terminal will be returned to a sane state before 
     * propagating the exception
     *)
    fun wrap func =
    let
        val _ = initscr()
        val _ = cbreak()
        val _ = noecho()
        val _ = keypad(stdscr, true)
    in
        fn args: 'a =>
        let
            val ret = func args
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