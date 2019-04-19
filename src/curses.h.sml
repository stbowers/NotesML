(* Loader for the curses library *)
structure CursesH = struct
    local
        val soname = "libncursesw.so"
        val lh = DynLinkage.open_lib {name = soname, global = true, lazy = true}
        val _ = print("Using curses library: " ^ soname ^ "\n");
    in
        fun libh s = let
            val sh = DynLinkage.lib_symbol (lh, s)
        in
            fn () => DynLinkage.addr sh
        end
    end
end