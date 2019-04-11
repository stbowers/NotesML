(* Loader for the curses library *)
structure CursesH = struct
    local
        val lh = DynLinkage.open_lib {name = "libncursesw.so", global = true, lazy = true}
    in
        fun libh s = let
            val sh = DynLinkage.lib_symbol (lh, s)
        in
            fn () => DynLinkage.addr sh
        end
    end
end