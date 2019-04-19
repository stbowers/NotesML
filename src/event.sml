
signature EVENT = sig
    datatype event = Quit of int | Input of MLRep.Signed.int

    val isQuit: event -> bool
end

structure Event :> EVENT = struct
    datatype event = Quit of int | Input of MLRep.Signed.int

    fun isQuit(Quit code) = true
        |isQuit(e) = false 
end