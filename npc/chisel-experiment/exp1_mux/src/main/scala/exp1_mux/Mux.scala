package exp1_mux

import chisel3._

class Mux extends Module {
	val io = IO(new Bundle {
			val y = Input(UInt(2.W))
			val x = Input(Vec(4, UInt(2.W)))
			val out = Output(UInt(2.W))
	})
	io.out := io.x(io.y)
}

object Mux extends App {
	println("Generating the Mux hardware")
	(new chisel3.stage.ChiselStage).emitVerilog(new Mux(), Array("--target-dir", "./vsrc/exp1_mux"))
}