package exp8_vga

import chisel3._

class VgaImg extends Module {
    val io = IO(new Bundle {
        val h_sync = Output(UInt(1.W))
        val v_sync = Output(UInt(1.W))
        val valid = Output(UInt(1.W))
        val vag_r = Output(UInt(8.W))
        val vag_g = Output(UInt(8.W))
        val vag_b = Output(UInt(8.W))
    })
    val vga_data = WireInit(0.U(24.W))
    val vgactrl = Module(new VgaCtrl)
    vgactrl.io.vga_data := vga_data
    io.h_sync := vgactrl.io.h_sync
    io.v_sync := vgactrl.io.v_sync
    io.valid := vgactrl.io.valid
    io.vag_r := vgactrl.io.vag_r
    io.vag_g := vgactrl.io.vag_g
    io.vag_b := vgactrl.io.vag_b

    val readimg = Module(new ReadImg)
    readimg.io.h_addr := vgactrl.io.h_addr
    readimg.io.v_addr := vgactrl.io.v_addr
    vga_data := readimg.io.vga_data
}

object VgaImg extends App {
    println("Generating the VgaImg hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new VgaImg(), Array("--target-dir", "./vsrc/exp8_vga"))
}