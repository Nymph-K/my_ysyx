#include <nvboard.h>
#include <Valu4b.h>
#include <stdio.h>
#include <stdlib.h>

static TOP_NAME dut;

void nvboard_bind_all_pins(Valu4b* top);

int main() {
  nvboard_bind_all_pins(&dut);
  nvboard_init();
  while(1) {
    nvboard_update();
	  dut.eval();
  }
  nvboard_quit();
}

