package exp3_alu

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec


class ALUTester extends AnyFlatSpec with ChiselScalatestTester {
    "ALUTester test" should "pass" in {
        test(new ALU(4)) { dut =>

            for (sel <- 0 to 7) {
                dut.io.sel.poke(sel.U)
                for (a <- -8 to 7) {
                    for (b <- -8 to 7) {
                        dut.io.a.poke(a.S)
                        dut.io.b.poke(b.S)
                        dut.clock.step(1)
                        val result =
                            sel match {
                                case 0 => a + b
                                case 1 => a - b
                                case 2 => ~a
                                case 3 => a & b
                                case 4 => a | b
                                case 5 => a ^ b
                                case 6 => if (a < b) 1 else 0
                                case 7 => if (a === b) 1 else 0
                            }
                        val resMask = result & 0xf
                        println(s"sel = $sel, a = $a, b = $b, resMask = $resMask, out = ${dut.io.out.peek()}")
                        //dut.io.out.expect(resMask.S(4.W))
                    }
                }
            }
        }
    }
}