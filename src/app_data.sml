signature APPDATA = sig
    type t_data

    val default: t_data
    val handle_events: t_data ref * Event.event list -> Event.event list

    val get_i: t_data -> int
    val set_i: t_data ref -> unit
end

structure AppData :> APPDATA = struct
    type t_data = {
        notes: string list,
        i: int
    }

    val default = {
        notes = ["Note1", "Note2", "Note3"],
        i = 0
    }

    (* Processes a single event, returning a list of any new events produced *)
    fun handle_event(data, Event.Quit code) = []
        |handle_event(data, Event.Input ch) =
        if ch = MLRep.Signed.fromInt (Char.ord #"q") then [Event.Quit 0]
        else []

    (* Processes a list of events, returning a list of any new events produced *)
    fun handle_events(data, events) = let
        fun handle_recursive(data, [], passed) = passed
            |handle_recursive(data, eh::et, passed) = handle_recursive(data, et, passed @ handle_event(data, eh))
    in
        handle_recursive(data, events, [])
    end

    fun get_i(data: t_data) = #i data
    fun set_i(data: t_data ref) = let
        val {notes, i} = !data
    in
        data := {i = i+1, notes = notes}
    end
end