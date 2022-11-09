package exp2_coder

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec


class Coder83Tester extends AnyFlatSpec with ChiselScalatestTester {
  	"Coder83Tester test" should "pass" in {
		test(new Coder83) { dut =>

			dut.io.en.poke(true.B)
			var expect_led = 0
			for (i <- 0 to 255) {
				dut.io.in.poke(i.U)
				dut.clock.step(1)        
        		expect_led = if (i == 0) 0 else log2Floor(i)
        		//println(s"i = $i  out = ${dut.io.out_led.peek()}  expect = $expect_led")
				if (i == 0) {
					dut.io.out_z.expect(true.B)
					dut.io.out_led.expect(0.U)
				}
				else {
					dut.io.out_z.expect(false.B)
					dut.io.out_led.expect(expect_led)
				}
			}
		}
	}
}