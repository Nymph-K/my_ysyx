package exp3_alu

import chisel3._
import chisel3.util._

class ALU(width: Int) extends Module {
    require(width > 0)
    val io = IO(new Bundle {
        val sel = Input(UInt(3.W))
        val a = Input(SInt(width.W))
        val b = Input(SInt(width.W))
        val out = Output(SInt(width.W))
        val zero = Output(Bool())
        val overflow = Output(Bool())
        val carry = Output(Bool())
    })

    val result = Wire(SInt((width + 1).W))
    result := 0.S
    io.out := result
    io.carry := result(width)
    io.zero := Mux((result === 0.S), true.B, false.B)
    io.overflow := Mux((result(width - 2) =/= result(width - 1)), true.B, false.B)

    switch(io.sel) {
        is("b000".U) {
            result := io.a +& io.b
        }
        is("b001".U) {
            result := io.a -& io.b
        }
        is("b010".U) {
            result := ~io.a
        }
        is("b011".U) {
            result := io.a & io.b
        }
        is("b100".U) {
            result := io.a | io.b
        }
        is("b101".U) {
            result := io.a ^ io.b
        }
        is("b110".U) {
            result := Mux((io.a < io.b), 1.S, 0.S)
        }
        is("b111".U) {
            result := Mux((io.a === io.b), 1.S, 0.S)
        }
    }
}

object ALU extends App {
    println("Generating the ALU hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new ALU(4), Array("--target-dir", "./vsrc/exp3_alu"))
}