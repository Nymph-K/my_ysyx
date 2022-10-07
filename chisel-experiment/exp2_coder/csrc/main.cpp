#include <nvboard.h>
#include <VCoder83.h>
#include <stdio.h>
#include <stdlib.h>


#define WAVE_TRACE 0
#if WAVE_TRACE
#include "verilated.h"
#include "verilated_vcd_c.h"



void nvboard_bind_all_pins(TOP_NAME* dut);

static void single_cycle(VerilatedContext* contextp, TOP_NAME* dut, VerilatedVcdC* tfp) {
  dut->clock = 0; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
  dut->clock = 1; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}

static void reset(VerilatedContext* contextp, TOP_NAME* dut, VerilatedVcdC* tfp, int n) {
  dut->rst = 1;
  while (n -- > 0) single_cycle(contextp, dut, tfp);
  dut->rst = 0;
}

int main() {
  VerilatedContext* contextp = new VerilatedContext;
  TOP_NAME* dut = new TOP_NAME{contextp};
  VerilatedVcdC* tfp = new VerilatedVcdC;
  contextp->traceEverOn(true);
  dut->trace(tfp, 0);
  tfp->open("wave.vcd");

  nvboard_bind_all_pins(dut);
  nvboard_init();

  reset(contextp, dut, tfp, 10);

  while(1) {
    nvboard_update();
	  single_cycle(contextp, dut, tfp);
  }
  tfp->close();
  delete contextp;
  nvboard_quit();
}

#else

void nvboard_bind_all_pins(TOP_NAME* dut);

static void single_cycle(TOP_NAME* dut) {
  dut->clock = 0; dut->eval();
  dut->clock = 1; dut->eval();
}

static void reset(TOP_NAME* dut, int n) {
  dut->reset = 1;
  while (n -- > 0) single_cycle(dut);
  dut->reset = 0;
}

int main() {
  VerilatedContext* contextp = new VerilatedContext;
  TOP_NAME* dut = new TOP_NAME{contextp};

  nvboard_bind_all_pins(dut);
  nvboard_init();

  //reset(dut, 10);

  while(1) {
    dut->eval();
    nvboard_update();
	  //single_cycle(dut);
  }
  delete contextp;
  nvboard_quit();
}

#endif