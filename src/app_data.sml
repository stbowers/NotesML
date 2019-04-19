signature APPDATA = sig
    type data_type

    val default: data_type
    val handle_events: data_type ref * Event.event list -> Event.event list
end

structure AppData :> APPDATA = struct
    type data_type = {
        notes: string list
    }

    val default = {
        notes = ["Note1", "Note2", "Note3"]
    }

    (* Processes a single event, returning a list of any new events produced *)
    fun handle_event(data, Event.Quit) = []
        |handle_event(data, Event.Input ch) = if ch = MLRep.Signed.fromInt (Char.ord #"q") then [Event.Quit] else []

    (* Processes a list of events, returning a list of any new events produced *)
    fun handle_events(data, events) = let
        fun handle_recursive(data, [], passed) = passed
            |handle_recursive(data, eh::et, passed) = handle_recursive(data, et, passed @ handle_event(data, eh))
    in
        handle_recursive(data, events, [])
    end
end