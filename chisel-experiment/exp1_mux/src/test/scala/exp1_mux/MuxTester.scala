package exp1_mux

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec


class MuxTester extends AnyFlatSpec with ChiselScalatestTester {

  "MuxTester test" should "pass" in {
    test(new Mux) { dut =>

		val xSeq = Seq(0, 1, 2, 3)
        for (i <- 0 to 3) {
			dut.io.x(i).poke(xSeq(i).U)
		}

        for (j <- 0 to 3) {
			dut.io.y.poke(j.U)
			dut.clock.step(1)
			dut.io.out.expect(j.U)
		}
    }
  }
}