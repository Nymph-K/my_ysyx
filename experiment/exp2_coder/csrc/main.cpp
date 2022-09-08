#include <nvboard.h>
#include <Vcoder83.h>
#include <stdio.h>
#include <stdlib.h>

static TOP_NAME dut;

void nvboard_bind_all_pins(Vcoder83* top);

int main() {
  nvboard_bind_all_pins(&dut);
  nvboard_init();
  while(1) {
    nvboard_update();
	dut.eval();
  }
  nvboard_quit();
}

