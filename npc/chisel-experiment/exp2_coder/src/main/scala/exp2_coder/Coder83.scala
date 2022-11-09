package exp2_coder

import chisel3._
import chisel3.util._

class Coder83 extends Module {
	val io = IO(new Bundle {
			val en = Input(Bool())
			val in = Input(UInt(8.W))
			val out_z = Output(Bool())
			val out_led = Output(UInt(3.W))
			val out_seg = Output(UInt(8.W))
	})

	val num2seg = Module(new Num2seg())
	num2seg.io.in := io.out_led

	when(io.en) {
		when(io.in === 0.U) {
			io.out_z := true.B
			io.out_led := 0.U
		}.otherwise {
			io.out_z := false.B
			io.out_led := 7.U - PriorityEncoder(Reverse(io.in))
		}
		io.out_seg := num2seg.io.out
	}.otherwise {
			io.out_z := false.B
			io.out_led := 0.U
			io.out_seg := "hff".U
	}
}

object Coder83 extends App {
	println("Generating the Coder83 hardware")
	(new chisel3.stage.ChiselStage).emitVerilog(new Coder83(), Array("--target-dir", "./vsrc/exp2_coder"))
}