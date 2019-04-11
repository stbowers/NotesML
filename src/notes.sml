structure Application =
struct
    fun main (prog_name, args) =
    let
        val _ = print "Hello\n"
        val _ = F_initscr.f ()
        val _ = F_printw.f (ZString.dupML "Hello, World!")
        val _ = F_refresh.f ()
        val _ = F_getch.f ()
        val _ = F_endwin.f ()
    in
      0
    end
end