package exp8_vga

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFileInline
import firrtl.annotations.MemoryLoadFileType

class ReadImg extends Module {
    val io = IO(new Bundle {
        val h_addr = Input(UInt(10.W))
        val v_addr = Input(UInt(10.W))
        val vga_data = Output(UInt(24.W))//RGB
    })
    val height = 480
    val width = 640
    val bfoffset = 54
    val total_size: Int = height * width * 3 + bfoffset
    val img_data = Mem(total_size, UInt(8.W))
    val r_data = WireInit(0.U(8.W))
    val g_data = WireInit(0.U(8.W))
    val b_data = WireInit(0.U(8.W))

    r_data := img_data.read(io.h_addr * 3.U + (479.U - io.v_addr) * 640.U * 3.U + 54.U + 2.U)
    g_data := img_data.read(io.h_addr * 3.U + (479.U - io.v_addr) * 640.U * 3.U + 54.U + 1.U)
    b_data := img_data.read(io.h_addr * 3.U + (479.U - io.v_addr) * 640.U * 3.U + 54.U + 0.U)
    io.vga_data := Cat(r_data, Cat(g_data, b_data))
    loadMemoryFromFileInline(img_data, "./resource/picture.bmp_hex.txt", MemoryLoadFileType.Hex)
}

object ReadImg extends App {
    println("Generating the ReadImg hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new ReadImg(), Array("--target-dir", "./vsrc/exp8_vga"))
}