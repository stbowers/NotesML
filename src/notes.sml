structure Application =
struct
    fun run(prog_name, args) = let
        val _ = Curses.printw("Hello, World!")
        val _ = Curses.getch()
    in
        0
    end

    fun main(prog_name, args) = (Curses.wrap run)(prog_name, args)
end