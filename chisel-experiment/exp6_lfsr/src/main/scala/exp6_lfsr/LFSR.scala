package exp6_lfsr

import chisel3._
import chisel3.util._

class LFSR(len:Int, tap:Int) extends Module {
    require(len > 0)
    require(tap > 0)
    val io = IO(new Bundle {
        val en = Input(Bool())
        val in = Input(UInt(len.W))
        val out = Output(UInt(len.W))
    })
    val result = RegInit(0.U(len.W))
    val xorresult = WireInit(0.U(1.W))
    xorresult := Mux((result & tap.U).xorR, 1.U, 0.U)
    when(io.en) {
        result := io.in
    }.otherwise {
        result := Cat(xorresult, result)(len,1)
    }
    io.out := result
}

object LFSR extends App {
    println("Generating the LFSR hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new LFSR(8, 0x1D), Array("--target-dir", "./vsrc/exp4_lfsr"))
}