signature APPDATA = sig
    type t_data

    val default: t_data
    val handle_events: t_data ref * Event.event list -> Event.event list

    val get_version: t_data ref -> string
    val get_notes: t_data ref -> string list
    val get_selected: t_data ref -> int
    val get_note_content: t_data ref * int -> string
end

structure AppData :> APPDATA = struct
    type t_data = {
        version: string,
        notes: string list ref,
        selected: int ref
    }

    val default = {
        version = "v0.1.0",
        notes = ref ["Note1", "Note2", "Note3"],
        selected = ref 0
    }

    (* Processes a single event, returning a list of any new events produced *)
    fun handle_event(data: t_data ref, Event.Quit code) = []
        |handle_event(data: t_data ref, Event.Input ch) =
        if ch = MLRep.Signed.fromInt (Char.ord #"q") then [Event.Quit 0]
        else if ch = MLRep.Signed.fromInt (Char.ord #"k") then (
            #selected (!data) := Int.max(0, !(#selected (!data)) - 1);
            []
        )
        else if ch = MLRep.Signed.fromInt (Char.ord #"j") then (
            #selected (!data) := Int.min(2, !(#selected (!data)) + 1);
            []
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
    fun get_note_content(data: t_data ref, index: int) = "" 
end