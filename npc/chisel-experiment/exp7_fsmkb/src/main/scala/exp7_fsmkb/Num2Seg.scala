package exp7_fsmkb

import chisel3._
import chisel3.util._

class Num2Seg() extends Module {
    val io = IO(new Bundle {
        val in = Input(UInt(8.W))
        val out = Output(UInt(16.W))
    })
    val coder = VecInit(Seq(
        "b00000011".U(8.W), //0
        "b10011111".U(8.W), //1
        "b00100101".U(8.W), //2
        "b00001101".U(8.W), //3
        "b10011001".U(8.W), //4
        "b01001001".U(8.W), //5
        "b01000001".U(8.W), //6
        "b00011111".U(8.W), //7
        "b00000001".U(8.W), //8
        "b00001001".U(8.W), //9
        "b00010001".U(8.W), //A
        "b11000001".U(8.W), //B
        "b01100011".U(8.W), //C
        "b10000101".U(8.W), //D
        "b01100001".U(8.W), //E
        "b01110001".U(8.W) //F
    ))
    io.out := Cat(coder(io.in(7, 4)), coder(io.in(3, 0)))
}

object Num2Seg extends App {
    println("Generating the Num2Seg hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new Num2Seg(), Array("--target-dir", "./vsrc/exp7_fsmkb"))
}