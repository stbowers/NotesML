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
    val get_content_index: t_data ref -> int
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
        content_cursor_x: int ref,
        content_lines: int ref,
        content_current_line_width: int ref
    }

    fun get_notes() =
    let
        val notes_dir = OS.FileSys.openDir "./notes"
        fun read_files(notes) = let val next_note = OS.FileSys.readDir notes_dir in
            case next_note of
                SOME note => let val note_name = String.substring (note, 0,
                String.size(note) - 4) in read_files(notes @ [note_name]) end
                |NONE => notes
        end
    in
        read_files([])
    end

    fun default() = let
    in 
        {
            version = "v0.1.0",
            notes = ref(["New Note"] @ get_notes()),
            selected = ref 0,
            mode = ref 0,

            content_cache = ref NONE: string option ref,
            content_cursor_line = ref 0,
            content_cursor_x = ref 0,
            content_lines = ref 0,
            content_current_line_width = ref 0
        }
    end

    fun write_back_note(data, 0) = ()
        |write_back_note(data: t_data ref, index: int) = let
        val content = case !(#content_cache (!data)) of
            SOME string => string
            |NONE => ""

        val original_name = List.nth(!(#notes (!data)), index)
        val original_file = "./notes/" ^ original_name ^ ".txt"

        val lines = String.fields (fn ch => ch = #"\n") content
        val name = List.nth(lines, 0)
        val file = "./notes/" ^ name ^ ".txt"

        val outstream = TextIO.openOut(file)
    in
        if content = "" then OS.FileSys.remove(original_file)
        else (
            OS.FileSys.rename{old = original_file, new = file};

            TextIO.output(outstream, content);
            TextIO.closeOut outstream;


            #notes (!data) := ["New Note"] @ get_notes();
            ()
        )
    end

    fun get_content_index(data: t_data ref) = case !(#content_cache (!data)) of
        NONE => 0
       |SOME content => let
            val lines = String.fields (fn ch => ch = #"\n") content
            fun get_line_index(lines, 0, running_index) = running_index
               |get_line_index(line_head::line_tail, line, running_index) =
                    get_line_index(line_tail, line - 1, running_index +
                        String.size(line_head) + 1)
        in
            get_line_index(lines, !(#content_cursor_line (!data)), !(#content_cursor_x (!data)))
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
            else if ch = MLRep.Signed.fromInt(Char.ord #"\t")
                orelse ch = MLRep.Signed.fromInt(Char.ord #"\n")
            then (
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
            if ch = MLRep.Signed.fromInt(Char.ord #"\t")
                orelse ch = MLRep.Signed.fromInt(27)
            then (
                write_back_note(data, !(#selected (!data)));
                #mode (!data) := 0;
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"h") then (
                #content_cursor_x (!data) := Int.max(0, !(#content_cursor_x (!data)) - 1);
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"l") then (
                #content_cursor_x (!data) := Int.min(!(#content_current_line_width (!data)), !(#content_cursor_x (!data)) + 1);
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"k") then (
                #content_cursor_line (!data) := Int.max(0,
                !(#content_cursor_line (!data)) - 1);

                case !(#content_cache (!data)) of
                    NONE => ()
                   |SOME content => let
                        val lines = String.fields (fn ch => ch = #"\n") content
                    in
                        #content_current_line_width (!data) :=
                        String.size(List.nth(lines, !(#content_cursor_line
                        (!data))))
                    end;

                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"j") then (
                #content_cursor_line (!data) := Int.min(!(#content_lines (!data)),
                !(#content_cursor_line (!data)) + 1);

                case !(#content_cache (!data)) of
                    NONE => ()
                   |SOME content => let
                        val lines = String.fields (fn ch => ch = #"\n") content
                    in
                        #content_current_line_width (!data) :=
                        String.size(List.nth(lines, !(#content_cursor_line
                        (!data))))
                    end;

                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"i") then (
                #mode (!data) := 2;
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"I") then (
                #mode (!data) := 2;
                #content_cursor_x (!data) := 0;
                []
            )
            else if ch = MLRep.Signed.fromInt(Char.ord #"A") then (
                #mode (!data) := 2;
                #content_cursor_x (!data) := !(#content_current_line_width (!data));
                []
            )
            else []
        end
        else if !(#mode (!data)) = 2 then (
            (* Mode 2 = insert note mode *)
            if ch = MLRep.Signed.fromInt(27) then (
                #mode (!data) := 1;
                #content_cursor_x (!data) := Int.max(0, !(#content_cursor_x (!data)) - 1);
                write_back_note(data, !(#selected (!data)));
                []
            )
            else if ch = MLRep.Signed.fromInt(127) then let
                val content_index = get_content_index(data)
            in
                case !(#content_cache (!data)) of
                    NONE => ()
                   |SOME content => (
                        #content_cursor_x (!data) := !(#content_cursor_x
                            (!data)) - 1;
                        #content_cache (!data) := SOME (String.extract(content,
                        0, SOME (content_index - 1)) ^
                        String.extract(content, content_index, NONE));
                        ()
                   );
                write_back_note(data, !(#selected (!data)));
                []
            end
            else if Char.isPrint(Char.chr(MLRep.Signed.toInt ch)) then let
                val content_index = get_content_index(data)
            in
                case !(#content_cache (!data)) of
                    NONE => ()
                   |SOME content => (
                        #content_cursor_x (!data) := !(#content_cursor_x
                            (!data)) + 1;
                        #content_cache (!data) := SOME (String.extract(content,
                        0, SOME content_index) ^
                        String.str(Char.chr(MLRep.Signed.toInt ch)) ^
                        String.extract(content, content_index, NONE));
                        ()
                   );
                write_back_note(data, !(#selected (!data)));
                []
            end
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
            val lines = String.fields (fn ch => ch = #"\n") content
        in
            #content_cache (!data) := SOME content;
            #content_lines (!data) := List.length(lines) - 1;
            #content_current_line_width (!data) := String.size(List.nth(lines, 0));
            content
        end
end
