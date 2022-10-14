package exp7_fsmkb

import chisel3._
import chisel3.util._

class KBDREC extends Module {
    val io = IO(new Bundle {
        val ps2_clk = Input(UInt(1.W))
        val ps2_data = Input(UInt(1.W))
        val data = Decoupled(UInt(8.W))
        val overflow = Output(Bool())
    })
    val ps2_clk_delay = RegInit(0.U(3.W))
    ps2_clk_delay := Cat(ps2_clk_delay(1,0), io.ps2_clk)
    val ps2_clk_negedge = WireDefault(0.U(1.W))
    ps2_clk_negedge := !ps2_clk_delay(1) & ps2_clk_delay(2)

    val valid = RegInit(false.B)
    io.data.valid := valid
    val bit_cnt = RegInit(0.U(4.W))
    val bit_buffer = RegInit(0.U(10.W))
    val data_fifo = RegInit(VecInit(Seq.fill(8)(0.U(8.W))))
    val data_of = RegInit(false.B)
    val rptr = RegInit(0.U(3.W))
    val wptr = RegInit(0.U(3.W))
    when(ps2_clk_negedge === 1.U) {
        when(bit_cnt === 10.U) {
            bit_cnt := 0.U
            when(bit_buffer(0) === 0.U && io.ps2_data === 1.U && bit_buffer(9, 1).xorR) {
                valid := true.B
                data_fifo(wptr) := bit_buffer(8, 1)
                wptr := wptr + 1.U
            }
        }.otherwise {
            bit_cnt := bit_cnt + 1.U
            bit_buffer := Cat(io.ps2_data, bit_buffer(9,1))
        }
    }
    when(valid & io.data.ready) {
        rptr := rptr + 1.U
        valid := !(rptr + 1.U === wptr)
    }
    io.data.bits := data_fifo(rptr)
    data_of := data_of | (rptr === (wptr + 1.U))
    io.overflow := data_of
}

object KBDREC extends App {
    println("Generating the KBDREC hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new KBDREC(), Array("--target-dir", "./vsrc/exp7_fsmkb"))
}

class BundleKB extends Bundle {
    val push = Bool()
    val release = Bool()
    val same = Bool()
    val cnt = UInt(2.W)
    val scancode = Vec(4, UInt(16.W))
}

class FSMKB extends Module {
    val io = IO(new Bundle {
        val ps2_clk = Input(UInt(1.W))
        val ps2_data = Input(UInt(1.W))
        val key = Decoupled(new BundleKB())
    })

    val idle :: singlepushed :: e0code :: multipushed :: releasing :: e0releasing :: Nil = Enum(6)
    val ns = WireInit(idle)
    val cs = RegInit(idle)
    val key_push = RegInit(false.B)
    val key_release = RegInit(false.B)
    val key_same = RegInit(false.B)
    val key_valid = RegInit(false.B)
    val key_buffer = Reg(Vec(4, UInt(16.W))) //four key max
    val key_cnt = RegInit(0.U(2.W)) //four key max
    val buffer_full = WireInit(false.B)
    val buffer_empty = WireInit(true.B)

    io.key.bits.push := key_push
    io.key.bits.release := key_release
    io.key.bits.same := key_same
    io.key.bits.cnt := key_cnt
    io.key.bits.scancode := key_buffer
    io.key.valid := key_valid
    buffer_full := (cs === multipushed) && (key_cnt === 0.U)
    buffer_empty := (cs === idle) && (key_cnt === 0.U)
    key_valid := !buffer_empty

    val kbdrec = Module(new KBDREC())
    kbdrec.io.ps2_clk := io.ps2_clk
    kbdrec.io.ps2_data := io.ps2_data
    kbdrec.io.data.ready := !buffer_full
/*
 * 1 normal key short : 1C F0 1C
 * 1 normal key long  : 1C 1C 1C ... F0 1C
 * 1 E0 key short     : E0 75 E0 F0 75
 * 1 E0 key long      : E0 75 E0 75 E0 75 ... E0 F0 75
 * 2 normal key short : 1C 12 F0 1C F0 12
 * 1 normal key 1 E0  : 1C E0 75 E0 F0 75 F0 1C
 * 1 normal key 1 E0 l: 1C E0 75 E0 75 E0 75 ... E0 F0 75 F0 1C
 */
    cs := ns
    when(kbdrec.io.data.valid) {
        switch(cs) {
            is(idle) {
                when(kbdrec.io.data.bits =/= 0xE0.U) {
                    ns := singlepushed
                }.otherwise {
                    ns := e0code
                }
            }
            is(singlepushed) {
                when(kbdrec.io.data.bits === 0xF0.U) { //release key
                    ns := releasing
                }.elsewhen(kbdrec.io.data.bits === 0xE0.U) { //E0 key
                    ns := e0code
                }.elsewhen(Cat(0.U(8.W), kbdrec.io.data.bits) =/= key_buffer(key_cnt - 1.U)) { //different key
                    ns := multipushed
                }.otherwise { //same key
                    ns := singlepushed
                }
            }
            is(e0code) {
                when(kbdrec.io.data.bits === 0xF0.U) {
                    ns := e0releasing
                }.elsewhen(key_cnt === 0.U) { //empty buffer
                    ns := singlepushed
                }.otherwise {
                    ns := multipushed //not empty
                }
            }
            is(multipushed) {
                when(kbdrec.io.data.bits === 0xF0.U) {
                    ns := releasing
                }.elsewhen(kbdrec.io.data.bits === 0xE0.U) {
                    ns := e0code
                }.elsewhen(Cat(0.U(8.W), kbdrec.io.data.bits) =/= key_buffer(key_cnt - 1.U)) { //different key
                    ns := multipushed
                }.otherwise { //same key
                    ns := multipushed
                }
            }
            is(releasing) {
                when(key_cnt === 1.U) {
                    ns := idle
                }.elsewhen(key_cnt === 2.U) {
                    ns := singlepushed
                }.elsewhen(key_cnt === 3.U) {
                    ns := multipushed
                }.otherwise {
                    ns := multipushed
                }
            }
            is(e0releasing) {
                when(key_cnt === 1.U) {
                    ns := idle
                }.elsewhen(key_cnt === 2.U) {
                    ns := singlepushed
                }.elsewhen(key_cnt === 3.U) {
                    ns := multipushed
                }.otherwise {
                    ns := multipushed
                }
            }
        }
    }.otherwise {
        ns := cs
    }

    switch(cs) {
        is(idle) {
            when(ns === singlepushed) {
                key_push := true.B
                key_release := false.B
                key_same := false.B
                key_buffer(key_cnt) := Cat(0.U(8.W), kbdrec.io.data.bits)
                key_cnt := key_cnt + 1.U
            }.otherwise {
                key_push := false.B
                key_release := false.B
                key_same := false.B
            }
        }
        is(singlepushed) {
            when(ns === multipushed) {//different key
                key_push := true.B
                key_release := false.B
                key_same := false.B
                key_buffer(key_cnt) := Cat(0.U(8.W), kbdrec.io.data.bits)
                key_cnt := key_cnt + 1.U
            }.elsewhen(kbdrec.io.data.valid && ns ===singlepushed) {//same key
                key_push := true.B
                key_release := false.B
                key_same := true.B
            }.otherwise {
                key_push := false.B
                key_release := false.B
                key_same := false.B
            }
        }
        is(e0code) {
            when(ns === singlepushed) {
                key_push := true.B
                key_release := false.B
                key_same := false.B
                key_cnt := key_cnt + 1.U
                key_buffer(key_cnt) := Cat(0xE0.U(8.W), kbdrec.io.data.bits)
            }.elsewhen(ns === multipushed) {
                key_push := true.B
                key_release := false.B
                when(Cat(0xE0.U(8.W), kbdrec.io.data.bits) =/= key_buffer(key_cnt - 1.U)) { //different key
                    key_same := false.B
                    key_buffer(key_cnt) := Cat(0xE0.U(8.W), kbdrec.io.data.bits)
                    key_cnt := key_cnt + 1.U
                }.otherwise { //same key
                    key_same := true.B
                }
            }.otherwise {
                key_push := false.B
                key_release := false.B
                key_same := false.B
            }
        }
        is(multipushed) {
            when(kbdrec.io.data.valid && ns === multipushed) {
                key_push := true.B
                key_release := false.B
                when(Cat(0.U(8.W), kbdrec.io.data.bits) =/= key_buffer(key_cnt - 1.U)) {//different key
                    key_same := false.B
                    key_buffer(key_cnt) := Cat(0.U(8.W), kbdrec.io.data.bits)
                    key_cnt := key_cnt + 1.U
                }.otherwise {//same key
                    key_same := true.B
                }
            }.otherwise {
                key_push := false.B
                key_release := false.B
                key_same := false.B
            }
        }
        is(releasing) {
            when(kbdrec.io.data.valid) {
                key_cnt := key_cnt - 1.U
                key_push := false.B
                key_release := true.B
                key_same := false.B
                when(ns === singlepushed) {
                    when(Cat(0.U(8.W), kbdrec.io.data.bits) === key_buffer(0)) {
                        key_buffer(0) := key_buffer(1)
                        key_buffer(1) := key_buffer(0)
                    }
                }.elsewhen(ns === multipushed) {
                    when(key_cnt === 3.U) {
                        when(Cat(0.U(8.W), kbdrec.io.data.bits) === key_buffer(0)) {
                            key_buffer(0) := key_buffer(1)
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(0)
                        }.elsewhen(Cat(0.U(8.W), kbdrec.io.data.bits) === key_buffer(1)) {
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(1)
                        }
                    }.otherwise {
                        when(Cat(0.U(8.W), kbdrec.io.data.bits) === key_buffer(0)) {
                            key_buffer(0) := key_buffer(1)
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(3)
                            key_buffer(3) := key_buffer(0)
                        }.elsewhen(Cat(0.U(8.W), kbdrec.io.data.bits) === key_buffer(1)) {
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(3)
                            key_buffer(3) := key_buffer(1)
                        }.elsewhen(Cat(0.U(8.W), kbdrec.io.data.bits) === key_buffer(2)) {
                            key_buffer(2) := key_buffer(3)
                            key_buffer(3) := key_buffer(2)
                        }
                    }
                }
            }.otherwise {
                key_push := false.B
                key_release := false.B
                key_same := false.B
            }
        }
        is(e0releasing) {
            when(kbdrec.io.data.valid) {
                key_cnt := key_cnt - 1.U
                key_push := false.B
                key_release := true.B
                key_same := false.B
                when(ns === singlepushed) {
                    when(Cat(0xE0.U(8.W), kbdrec.io.data.bits) === key_buffer(0)) {
                        key_buffer(0) := key_buffer(1)
                        key_buffer(1) := key_buffer(0)
                    }
                }.elsewhen(ns === multipushed) {
                    when(key_cnt === 3.U) {
                        when(Cat(0xE0.U(8.W), kbdrec.io.data.bits) === key_buffer(0)) {
                            key_buffer(0) := key_buffer(1)
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(0)
                        }.elsewhen(Cat(0xE0.U(8.W), kbdrec.io.data.bits) === key_buffer(1)) {
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(1)
                        }
                    }.otherwise {
                        when(Cat(0xE0.U(8.W), kbdrec.io.data.bits) === key_buffer(0)) {
                            key_buffer(0) := key_buffer(1)
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(3)
                            key_buffer(3) := key_buffer(0)
                        }.elsewhen(Cat(0xE0.U(8.W), kbdrec.io.data.bits) === key_buffer(1)) {
                            key_buffer(1) := key_buffer(2)
                            key_buffer(2) := key_buffer(3)
                            key_buffer(3) := key_buffer(1)
                        }.elsewhen(Cat(0xE0.U(8.W), kbdrec.io.data.bits) === key_buffer(2)) {
                            key_buffer(2) := key_buffer(3)
                            key_buffer(3) := key_buffer(2)
                        }
                    }
                }
            }.otherwise {
                key_push := false.B
                key_release := false.B
                key_same := false.B
            }
        }
    }
}



object FSMKB extends App {
    println("Generating the FSMKB hardware")
    (new chisel3.stage.ChiselStage).emitVerilog(new FSMKB(), Array("--target-dir", "./vsrc/exp7_fsmkb"))
}