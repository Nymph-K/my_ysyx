package exp8_vga

import chisel3._

class VgaCtrl extends Module {
    val io = IO(new Bundle {
        val vga_data = Input(UInt(24.W))//R-G-B
        val h_addr = Output(UInt(10.W))
        val v_addr = Output(UInt(10.W))
        val h_sync = Output(UInt(1.W))
        val v_sync = Output(UInt(1.W))
        val valid = Output(UInt(1.W))
        val vag_r = Output(UInt(8.W))
        val vag_g = Output(UInt(8.W))
        val vag_b = Output(UInt(8.W))
    })
    val h_frontporch = 96.U
    val h_active = 144.U
    val h_backporch = 784.U
    val h_total = 800.U
    val v_frontporch = 2.U
    val v_active = 35.U
    val v_backporch = 515.U
    val v_total = 525.U

    val x_cnt = RegInit(1.U(10.W))
    val y_cnt = RegInit(1.U(10.W))
    when(x_cnt === h_total) {
        x_cnt := 1.U
        when (y_cnt === v_total) {
            y_cnt := 1.U
        }.otherwise {
            y_cnt := y_cnt + 1.U
        }
    }.otherwise {
        x_cnt := x_cnt + 1.U
    }

    val h_addr = WireInit(0.U(10.W))
    val v_addr = WireInit(0.U(10.W))
    val h_sync = WireInit(1.U(1.W))
    val v_sync = WireInit(1.U(1.W))
    val h_valid = WireInit(0.U(1.W))
    val v_valid = WireInit(0.U(1.W))
    val valid = WireInit(0.U(1.W))

    h_sync := Mux(x_cnt > h_frontporch, 1.U, 0.U)
    v_sync := Mux(y_cnt > v_frontporch, 1.U, 0.U)
    h_valid := Mux(h_active < x_cnt && x_cnt <= h_backporch, 1.U, 0.U)
    v_valid := Mux(v_active < y_cnt && y_cnt <= v_backporch, 1.U, 0.U)
    valid := h_valid & v_valid

    h_addr := Mux(h_valid === 1.U, x_cnt - h_active - 1.U, 0.U)
    v_addr := Mux(v_valid === 1.U, y_cnt - v_active - 1.U, 0.U)

    io.h_addr := h_addr
    io.v_addr := v_addr
    io.h_sync := h_sync
    io.v_sync := v_sync
    io.valid := valid
    io.vag_r := io.vga_data(23, 16)
    io.vag_g := io.vga_data(15, 8)
    io.vag_b := io.vga_data(7,0)
}
