signature APPDATA = sig
    type t_data

    val default: unit -> t_data
    val handle_events: t_data ref * Event.event list -> Event.event list

    val get_version: t_data ref -> string
    val get_notes: t_data ref -> string list
    val get_selected: t_data ref -> int
    val get_mode: t_data ref -> int
    val get_content_cursor_line: t_data ref -> int
    val get_content_cursor_x: t_data ref -> int

    val get_note_content: t_data ref * int -> string
    val write_back_note: t_data ref * int -> unit
end

structure AppData :> APPDATA = struct
    (* version: the version string
     * notes: A list of note names
     * selected: the currently selected note (index into notes)
     * mode: the current mode, one of (switch with tab):
     *   0 - browser mode, input is used to select a note in the note browser
     *   1 - normal note mode, input is used to navigate inside the note (vim-style)
     *   2 - insert note mode, input is used to modify the note
     *   3 - visual note mode, input is used to modify a visual selection in the note
     *
     * content_cache: If SOME, stores a cache of the current content to be able to use without reading/writing to the file every frame
     * content_cursor: index into content string where the cursor is
     *)
    type t_data = {
        version: string,
        notes: string list ref,
        selected: int ref,
        mode: int ref,

        content_cache: string option ref,
        content_cursor_line: int ref,
        content_cursor_x: int ref
    }

    fun default() = let
        val notes_dir = OS.FileSys.openDir "./notes"
        fun get_notes(notes) = let val next_note = OS.FileSys.readDir notes_dir in
            case next_note of
                SOME note => let val note_name = String.substring (note, 0, String.size(note) - 4) in get_notes(notes @ [note_name]) end
                |NONE => notes
        end
    in 
        {
            version = "v0.1.0",
            notes = ref(get_notes(["New Note"])),
            selected = ref 0,
            mode = ref 0,

            content_cache = ref NONE: string option ref,
            content_cursor_line = ref 0,
            content_cursor_x = ref 0
        }
    end

    fun write_back_note(data, 0) = ()
        |write_back_note(data: t_data ref, index: int) = let
        val content = case !(#content_cache (!data)) of
            SOME string => string
            |NONE => ""
        
        val note = List.nth(!(#notes (!data)), index)
        val filename = "./notes/" ^ note ^ ".txt"
        val outstream = TextIO.openOut(filename)
    in
        TextIO.output(outstream, content);
        TextIO.closeOut outstream;
        ()
    end

    (* Processes a single event, returning a list of any new events produced *)
    fun handle_event(data: t_data ref, Event.Quit code) = []
        |handle_event(data: t_data ref, Event.Input ch) =
        if ch = MLRep.Signed.fromInt (Char.ord #"q") then [Event.Quit 0]
        else if !(#mode (!data)) = 0 then (
            if ch = MLRep.Signed.fromInt (Char.ord #"k") then (
                write_back_note(data, !(#selected (!data)));
                #selected (!data) := Int.max(0, !(#selected (!data)) - 1);
                #content_cache (!data) := NONE; (* Invalidate cache *)
                []
            )
            else if ch = MLRep.Signed.fromInt (Char.ord #"j") then (
                write_back_note(data, !(#selected (!data)));
                #selected (!data) := Int.min(List.length(!(#notes (!data))) - 1, !(#selected (!data)) + 1);
                #content_cache (!data) := NONE; (* Invalidate cache *)
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"\t") then (
                #mode (!data) := 1;
                if !(#selected (!data)) = 0 then (
                    #notes (!data) := (!(#notes (!data)) @ [""]);
                    #selected (!data) := (List.length(!(#notes (!data))) - 1);
                    ()
                ) else ();
                []
            )
            else []
        )
        else if !(#mode (!data)) = 1 then let
            in
            if ch = MLRep.Signed.fromInt(Char.ord #"\t") then (
                #mode (!data) := 0;
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"h") then (
                #content_cursor_x (!data) := Int.max(0, !(#content_cursor_x (!data)) - 1);
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"l") then (
                #content_cursor_x (!data) := Int.min(3, !(#content_cursor_x (!data)) + 1);
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"k") then (
                #content_cursor_line (!data) := Int.max(0,
                !(#content_cursor_line (!data)) - 1);
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"j") then (
                #content_cursor_line (!data) := Int.min(4,
                !(#content_cursor_line (!data)) + 1);
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"i") then (
                #mode (!data) := 2;
                []
            )
            else []
        end
        else if !(#mode (!data)) = 2 then (
            (* Mode 2 = insert note mode *)
            if ch = MLRep.Signed.fromInt(27) then (
                #mode (!data) := 1;
                []
            )
            else []
        )
        else []

    (* Processes a list of events, returning a list of any new events produced *)
    fun handle_events(data, events) = let
        fun handle_recursive(data, [], passed) = passed
            |handle_recursive(data, eh::et, passed) = handle_recursive(data, et, passed @ handle_event(data, eh))
    in
        handle_recursive(data, events, [])
    end

    fun get_version(data: t_data ref) = #version (!data)
    fun get_notes(data: t_data ref) = !(#notes (!data))
    fun get_selected(data: t_data ref) = !(#selected (!data))
    fun get_mode(data: t_data ref) = !(#mode (!data))
    fun get_content_cursor_line(data: t_data ref) = !(#content_cursor_line (!data))
    fun get_content_cursor_x(data: t_data ref) = !(#content_cursor_x (!data))

    fun get_note_content(data: t_data ref, index: int) = case !(#content_cache (!data)) of
        SOME content => content
        |NONE => let
            fun load_from_file() = let
                val note = List.nth(!(#notes (!data)), index)
                val filename = "./notes/" ^ note ^ ".txt"
                val instream = TextIO.openIn(filename)
                val file_text: string = TextIO.inputAll instream
            in
                TextIO.closeIn instream;
                file_text
            end
            handle _ => "Error reading file: " ^ List.nth(!(#notes (!data)), index) ^ ".txt"

            val content = if index = 0 then "" else load_from_file()
        in
            #content_cache (!data) := SOME content;
            content
        end

end
