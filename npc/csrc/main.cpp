//#include <nvboard.h>
#include <Vtop.h>
#include "svdpi.h"//DPI-C
#include "Vtop__Dpi.h"//DPI-C
#include <stdio.h>
#include <stdlib.h>

#define STACK_DP 40960
#define NUM_INST (u_int64_t)-1

#define FILE_NAME "/home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/bubble-sort-riscv64-nemu.bin"


static bool stopcpu = false;
void stopCPU(void)
{
  stopcpu = true;
}

//void nvboard_bind_all_pins(TOP_NAME* dut);

static VerilatedContext* contextp = new VerilatedContext;
static TOP_NAME* dut = new TOP_NAME{contextp};

#define WAVE_TRACE 1
#if WAVE_TRACE
#include "verilated.h"
#include "verilated_vcd_c.h"

static VerilatedVcdC* tfp = new VerilatedVcdC;

static void single_cycle() {
  dut->clk = 0; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
  dut->clk = 1; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}

#else

static void single_cycle() {
  dut->clk = 0; dut->eval();
  dut->clk = 1; dut->eval();
}

#endif

static void reset(int n) {
  dut->rst = 1;
  while (n -- > 0) single_cycle();
  dut->rst = 0;
  dut->eval();
}

int main() {

  // nvboard_bind_all_pins(dut);
  // nvboard_init();

#if WAVE_TRACE
  contextp->traceEverOn(true);
  dut->trace(tfp, 0);
  tfp->open("wave.vcd");
#endif

  reset(10);

  u_int32_t inst = 0;
  u_int64_t offset = 0;
  u_int8_t mem_data[STACK_DP] = {0,};
  FILE *binFile = fopen(FILE_NAME, "rb");
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
    dut->mem_rdata = *((u_int64_t *)(mem_data+offset));
   //printf("load  = 0x%16lX      data = 0x%16lX      mem = 0x%16lX\n", dut->mem_addr, dut->mem_rdata, *((u_int64_t *)(mem_data+offset)));
  }
  if (dut->mem_w)
  {
    offset = dut->mem_addr - 0x80000000;
    switch (dut->mem_dlen)
    {
      case 0:
        *((u_int8_t *)(mem_data+offset)) = (u_int8_t)dut->mem_wdata;break;
      case 1:
        *((u_int16_t *)(mem_data+offset)) = (u_int16_t)dut->mem_wdata;break;
      case 2:
        *((u_int32_t *)(mem_data+offset)) = (u_int32_t)dut->mem_wdata;break;
      case 3:
        *((u_int64_t *)(mem_data+offset)) = (u_int64_t)dut->mem_wdata;break;
      default:
        break;
    }
   //printf("store = 0x%16lX      data = 0x%16lX      mem = 0x%16lX\n", dut->mem_addr, dut->mem_wdata, *((u_int64_t *)(mem_data+offset)));
  }
  dut->eval();
#if WAVE_TRACE
  tfp->dump(contextp->time());contextp->timeInc(1);
#endif
  while(!stopcpu)// && dut->dnpc >= 0x80000000
  {
    dut->clk = 1;
    dut->eval();
    offset = dut->pc - 0x80000000;
    //printf("pc = 0x%16lX      ", dut->pc);
    inst = *((u_int32_t *)(mem_data+offset));
    dut->inst = inst;
    dut->eval();
    //printf("dnpc = 0x%16lX      \n", dut->dnpc);
    if (dut->mem_r)
    {
    offset = dut->mem_addr - 0x80000000;
    dut->mem_rdata = *((u_int64_t *)(mem_data+offset));
   //printf("load  = 0x%16lX      data = 0x%16lX      mem = 0x%16lX\n", dut->mem_addr, dut->mem_rdata, *((u_int64_t *)(mem_data+offset)));
    }
    if (dut->mem_w)
    {
    offset = dut->mem_addr - 0x80000000;
    switch (dut->mem_dlen)
    {
      case 0:
        *((u_int8_t *)(mem_data+offset)) = (u_int8_t)dut->mem_wdata;break;
      case 1:
        *((u_int16_t *)(mem_data+offset)) = (u_int16_t)dut->mem_wdata;break;
      case 2:
        *((u_int32_t *)(mem_data+offset)) = (u_int32_t)dut->mem_wdata;break;
      case 3:
        *((u_int64_t *)(mem_data+offset)) = (u_int64_t)dut->mem_wdata;break;
      default:
        break;
    }
   //printf("store = 0x%16lX      data = 0x%16lX      mem = 0x%16lX\n", dut->mem_addr, dut->mem_wdata, *((u_int64_t *)(mem_data+offset)));
    }
    
    dut->eval();
#if WAVE_TRACE
    tfp->dump(contextp->time());contextp->timeInc(1);
#endif
    dut->clk = 0;
    dut->eval();
#if WAVE_TRACE
    tfp->dump(contextp->time());;contextp->timeInc(1);
#endif
  }
  printf("CPU ebreak! pc = 0x%16lX\n", dut->pc);
#if WAVE_TRACE
  tfp->close();
#endif
  delete contextp;
}