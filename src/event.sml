
signature EVENT = sig
    datatype event = Quit | Input of MLRep.Signed.int

    val fromChar: MLRep.Signed.int -> event

    val isQuit: event -> bool
end

structure Event :> EVENT = struct
    datatype event = Quit | Input of MLRep.Signed.int
    fun fromChar(ch) = Input ch
    fun isQuit(Quit) = true
        |isQuit(e) = false 
end