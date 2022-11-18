//#include <nvboard.h>
#include <Vtop.h>
#include <stdio.h>
#include <stdlib.h>

#define STACK_DP 36864
#define NUM_INST 24
#define BIN_FILE_PATH "/home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/dummy-riscv64-nemu.bin"

#define WAVE_TRACE 1
#if WAVE_TRACE
#include "verilated.h"
#include "verilated_vcd_c.h"


static void single_cycle(VerilatedContext* contextp, TOP_NAME* dut, VerilatedVcdC* tfp) {
  dut->clk = 0; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
  dut->clk = 1; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}

static void reset(VerilatedContext* contextp, TOP_NAME* dut, VerilatedVcdC* tfp, int n) {
  dut->rst = 1;
  while (n -- > 0) single_cycle(contextp, dut, tfp);
  dut->rst = 0;
  dut->eval();
}

int main() {
  VerilatedContext* contextp = new VerilatedContext;
  TOP_NAME* dut = new TOP_NAME{contextp};
  VerilatedVcdC* tfp = new VerilatedVcdC;
  contextp->traceEverOn(true);
  dut->trace(tfp, 0);
  tfp->open("wave.vcd");

  reset(contextp, dut, tfp, 10);

  u_int32_t inst = 0;
  u_int64_t offset = 0;
  u_int8_t mem_data[STACK_DP] = {0,};
  FILE *binFile = fopen(BIN_FILE_PATH, "rb");
  fread(mem_data, 1, STACK_DP, binFile);
  fclose(binFile);

  dut->clk = 0;
  dut->eval();
  offset = dut->pc - 0x80000000;
  inst = *((u_int32_t *)(mem_data+offset));
  dut->inst = inst;
  dut->eval();
  if (dut->mem_r)
  {
    offset = dut->mem_addr - 0x80000000;
    dut->mem_data = *((u_int64_t *)(mem_data+offset));
  }
  if (dut->mem_w)
  {
    offset = dut->mem_addr - 0x80000000;
    switch (dut->mem_dlen)
    {
      case 0:
        *((u_int8_t *)(mem_data+offset)) = dut->mem_data;break;
      case 1:
        *((u_int16_t *)(mem_data+offset)) = dut->mem_data;break;
      case 2:
        *((u_int32_t *)(mem_data+offset)) = dut->mem_data;break;
      case 3:
        *((u_int64_t *)(mem_data+offset)) = dut->mem_data;break;
      default:
        break;
    }
  }
  dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
  for (int i = 0; i < NUM_INST; i++)
  {
    dut->clk = 1;
    dut->eval();
    offset = dut->pc - 0x80000000;
    inst = *((u_int32_t *)(mem_data+offset));
    dut->inst = inst;
    dut->eval();
    if (dut->mem_r)
    {
      offset = dut->mem_addr - 0x80000000;
      dut->mem_data = *((u_int64_t *)(mem_data+offset));
    }
    if (dut->mem_w)
    {
      offset = dut->mem_addr - 0x80000000;
      switch (dut->mem_dlen)
      {
        case 0:
          *((u_int8_t *)(mem_data+offset)) = dut->mem_data;break;
        case 1:
          *((u_int16_t *)(mem_data+offset)) = dut->mem_data;break;
        case 2:
          *((u_int32_t *)(mem_data+offset)) = dut->mem_data;break;
        case 3:
          *((u_int64_t *)(mem_data+offset)) = dut->mem_data;break;
        default:
          break;
      }
    }
    
    dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
    dut->clk = 0;
    dut->eval();tfp->dump(contextp->time());;contextp->timeInc(1);
    
  }
  tfp->close();
  delete contextp;
}

#else

//void nvboard_bind_all_pins(TOP_NAME* dut);

static void single_cycle(TOP_NAME* dut) {
  dut->clk = 0; dut->eval();
  dut->clk = 1; dut->eval();
}

static void reset(TOP_NAME* dut, int n) {
  dut->rst = 1;
  while (n -- > 0) single_cycle(dut);
  dut->rst = 0;
}


int main() {
  VerilatedContext* contextp = new VerilatedContext;
  TOP_NAME* dut = new TOP_NAME{contextp};

  // nvboard_bind_all_pins(dut);
  // nvboard_init();

  reset(dut, 10);
  u_int32_t inst = 0;
  u_int64_t offset = 0;
  u_int8_t mem_data[4096] = {0,};
  FILE *binFile = fopen(BIN_FILE_PATH, "rb");
  fread(mem_data, 1, 4096, binFile);
  fclose(binFile);

  for (int i = 0; i < NUM_INST; i++)
  {
    dut->clk = 0;
    //nvboard_update();
    offset = dut->pc - 0x80000000;
    inst = *((u_int32_t *)(mem_data+offset));
    dut->inst = inst;
    dut->eval();
    if (dut->mem_r)
    {
      offset = dut->mem_addr - 0x80000000;
      dut->mem_data = *((u_int64_t *)(mem_data+offset));
    }
    if (dut->mem_w)
    {
      offset = dut->mem_addr - 0x80000000;
      switch (dut->mem_dlen)
      {
        case 0:
          *((u_int8_t *)(mem_data+offset)) = dut->mem_data;break;
        case 1:
          *((u_int16_t *)(mem_data+offset)) = dut->mem_data;break;
        case 2:
          *((u_int32_t *)(mem_data+offset)) = dut->mem_data;break;
        case 3:
          *((u_int64_t *)(mem_data+offset)) = dut->mem_data;break;
        default:
          break;
      }
    }
    dut->eval();
    dut->clk = 1;
    dut->eval();
    
  }
  delete contextp;
  //nvboard_quit();
}

#endif