#include <nvboard.h>
#include <Vlfsr.h>
#include <stdio.h>
#include <stdlib.h>

static TOP_NAME dut;

void nvboard_bind_all_pins(Vlfsr* top);

int main() {
  nvboard_bind_all_pins(&dut);
  nvboard_init();
  while(1) {
    nvboard_update();
	  dut.eval();
  }
  nvboard_quit();
}

