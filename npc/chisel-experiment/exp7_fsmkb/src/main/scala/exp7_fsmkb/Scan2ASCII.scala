package exp7_fsmkb

import chisel3._
import chisel3.util._

class Scan2ASCII extends Module {
    val io = IO(new Bundle {
        val ps2_clk = Input(UInt(1.W))
        val ps2_data = Input(UInt(1.W))
        val shift = Output(Bool())
        val ctrl = Output(Bool())
        val alt = Output(Bool())
        val seg_scancode = Output(UInt(16.W))
        val seg_asciicode = Output(UInt(16.W))
        val seg_close = Output(UInt(16.W))
        val seg_times = Output(UInt(16.W))
    })

    val LSHIFT = 0x12.U(8.W)
    val RSHIFT = 0x59.U(8.W)
    val CTRL  = 0x14.U(8.W)
    val ALT   = 0x11.U(8.W)

    val scancode = RegInit(0.U(8.W))
    val asciicode = WireInit(0.U(8.W))
    val times = RegInit(0.U(8.W))
    val shift = RegInit(false.B)
    val ctrl = RegInit(false.B)
    val alt = RegInit(false.B)

    val fsmkb = Module(new FSMKB())
    val valid = WireInit(false.B)
    val push = WireInit(false.B)
    val release = WireInit(false.B)
    val same = WireInit(false.B)
    val cnt = WireInit(0.U(2.W))
    fsmkb.io.ps2_clk := io.ps2_clk
    fsmkb.io.ps2_data := io.ps2_data
    fsmkb.io.key.ready := true.B
    valid := fsmkb.io.key.valid
    push := fsmkb.io.key.bits.push
    release := fsmkb.io.key.bits.release
    same := fsmkb.io.key.bits.same
    cnt := fsmkb.io.key.bits.cnt

    when(push && !same) {
        times := times + 1.U
        scancode := fsmkb.io.key.bits.scancode(cnt - 1.U)(7, 0)
        shift := Mux((fsmkb.io.key.bits.scancode(cnt - 1.U)(7, 0) === RSHIFT) || (fsmkb.io.key.bits.scancode(cnt - 1.U)(7, 0) === LSHIFT), true.B, shift)
        ctrl := Mux(fsmkb.io.key.bits.scancode(cnt - 1.U)(7, 0) === CTRL, true.B, ctrl)
        alt := Mux(fsmkb.io.key.bits.scancode(cnt - 1.U)(7, 0) === ALT, true.B, alt)
    }
    when(release) {
        when(cnt =/= 0.U) {
            scancode := fsmkb.io.key.bits.scancode(cnt - 1.U)(7, 0)
            shift := Mux((fsmkb.io.key.bits.scancode(cnt)(7, 0) === RSHIFT) || (fsmkb.io.key.bits.scancode(cnt)(7, 0) === LSHIFT), false.B, shift)
            ctrl := Mux(fsmkb.io.key.bits.scancode(cnt)(7, 0) === CTRL, false.B, ctrl)
            alt := Mux(fsmkb.io.key.bits.scancode(cnt)(7, 0) === ALT, false.B, alt)
        }.otherwise {
            scancode := 0.U
            shift := false.B
            ctrl := false.B
            alt := false.B
        }
    }

    val code_table = VecInit(Seq(
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0900.U(16.W),
        0x607E.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x7151.U(16.W),
        0x3121.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x7A5A.U(16.W),
        0x7353.U(16.W),
        0x6141.U(16.W),
        0x7757.U(16.W),
        0x3240.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x6343.U(16.W),
        0x7858.U(16.W),
        0x6444.U(16.W),
        0x6545.U(16.W),
        0x3424.U(16.W),
        0x3323.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x2000.U(16.W),
        0x7656.U(16.W),
        0x6646.U(16.W),
        0x7454.U(16.W),
        0x7252.U(16.W),
        0x3525.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x6E4E.U(16.W),
        0x6242.U(16.W),
        0x6848.U(16.W),
        0x6747.U(16.W),
        0x7959.U(16.W),
        0x365E.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x6D4D.U(16.W),
        0x6A4A.U(16.W),
        0x7555.U(16.W),
        0x3726.U(16.W),
        0x382A.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x2C3C.U(16.W),
        0x6B4B.U(16.W),
        0x6949.U(16.W),
        0x6F4F.U(16.W),
        0x3029.U(16.W),
        0x3928.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x2E3E.U(16.W),
        0x2F3F.U(16.W),
        0x6C4C.U(16.W),
        0x3B3A.U(16.W),
        0x7050.U(16.W),
        0x2D5F.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x2722.U(16.W),
        0x0000.U(16.W),
        0x5B7B.U(16.W),
        0x3D2B.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0D00.U(16.W),
        0x5D7D.U(16.W),
        0x0000.U(16.W),
        0x5C7C.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0800.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x3100.U(16.W),
        0x0000.U(16.W),
        0x3400.U(16.W),
        0x3700.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x3000.U(16.W),
        0x2E00.U(16.W),
        0x3200.U(16.W),
        0x3500.U(16.W),
        0x3600.U(16.W),
        0x3800.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x2B00.U(16.W),
        0x3300.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x3900.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0xF700.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W),
        0x0000.U(16.W)
    ))
    asciicode := Mux(shift, code_table(scancode)(7,0), code_table(scancode)(15,8))

    val num2seg0 = Module(new Num2Seg())
    num2seg0.io.in := scancode
    val num2seg1 = Module(new Num2Seg())
    num2seg1.io.in := times
    val num2seg3 = Module(new Num2Seg())
    num2seg3.io.in := asciicode

    io.seg_asciicode := num2seg3.io.out
    io.seg_times := num2seg1.io.out
    io.seg_scancode := num2seg0.io.out
    io.seg_close := 0xFFFF.U(16.W)
    io.shift := shift
    io.ctrl := ctrl
    io.alt := alt
}

object Scan2ASCII extends App {
    println("Generating the Scan2ASCII hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new Scan2ASCII(), Array("--target-dir", "./vsrc/exp7_fsmkb"))
}