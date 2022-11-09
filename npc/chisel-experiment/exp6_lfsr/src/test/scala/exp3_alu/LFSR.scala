package exp6_lfsr

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class LFSRTester extends AnyFlatSpec with ChiselScalatestTester {
    "LFSRTester test" should "pass" in {
        test(new LFSR(8, 0x1D)) { dut =>
            dut.io.in.poke(1.U)
            dut.io.en.poke(true.B)
            dut.clock.step(1)
            dut.io.en.poke(false.B)
            for (i <- 0 to 256) {
                dut.clock.step(1)
                println(s"i = $i, out = ${dut.io.out.peek()}")
            }
        }
    }
}