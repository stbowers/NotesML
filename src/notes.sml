structure Application =
struct
    fun has_ch([], ch) = false
        |has_ch(xh::xt, ch) =
            if xh = (MLRep.Signed.fromInt (Char.ord ch)) then true
            else has_ch(xt, ch)

    fun run(stdscr, (prog_name, args)) = let
        val _ = Curses.printw("Hello, World!")
        val _ = Curses.addch(#"A")
        val run = ref true
        val events = ref []
    in
        while !run do
        (
            events := Window.poll_events(stdscr, true);
            if has_ch(!events, #"q") then (run := false)
            else (run := true)
        );
        0
    end

    fun main(prog_name, args) = (Curses.wrap run)(prog_name, args)
end