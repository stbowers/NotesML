signature APPDATA = sig
    type t_data

    val default: t_data
    val handle_events: t_data ref * Event.event list -> Event.event list

    val get_version: t_data ref -> string
    val get_notes: t_data ref -> string list
    val get_selected: t_data ref -> int
    val get_mode: t_data ref -> int
    val get_note_content: t_data ref * int -> string
end

structure AppData :> APPDATA = struct
    (* version: the version string
     * notes: A list of note names
     * selected: the currently selected note (index into notes)
     * mode: the current mode, one of (switch with tab):
     *   0 - browser mode, input is used to select a note in the note browser
     *   1 - note mode, input is used to write in the note
     *)
    type t_data = {
        version: string,
        notes: string list ref,
        selected: int ref,
        mode: int ref
    }

    val default = let
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
            mode = ref 0
        }
    end

    (* Processes a single event, returning a list of any new events produced *)
    fun handle_event(data: t_data ref, Event.Quit code) = []
        |handle_event(data: t_data ref, Event.Input ch) =
        if ch = MLRep.Signed.fromInt (Char.ord #"q") then [Event.Quit 0]
        else if !(#mode (!data)) = 0 then (
            if ch = MLRep.Signed.fromInt (Char.ord #"k") then (
                #selected (!data) := Int.max(0, !(#selected (!data)) - 1);
                []
            )
            else if ch = MLRep.Signed.fromInt (Char.ord #"j") then (
                #selected (!data) := Int.min(List.length(!(#notes (!data))) - 1, !(#selected (!data)) + 1);
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
        else if !(#mode (!data)) = 1 then (
            if ch = MLRep.Signed.fromInt(Char.ord #"\t") then (
                #mode (!data) := 0;
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
    fun get_note_content(data: t_data ref, 0) = "" (* Index 0 = New Note, contents should be blank *)
        |get_note_content(data: t_data ref, index: int) = let
        val note = List.nth(!(#notes (!data)), index)
        val filename = "./notes/" ^ note ^ ".txt"
        val instream = TextIO.openIn(filename)
        val file_text = TextIO.inputAll instream
    in
        TextIO.closeIn instream;
        file_text
    end
    handle _ => "Error reading file: " ^ List.nth(!(#notes (!data)), index) ^ ".txt"
end