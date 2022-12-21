//#include <nvboard.h>
#include <Vtop.h>
#include "svdpi.h"//DPI-C
#include "Vtop__Dpi.h"//DPI-C
#include "Vtop___024root.h"//dut->rootp
#include <stdio.h>
#include <stdlib.h>
#include </home/k/ysyx-workbench/nemu/include/macro.h>//IFDEF

#define WAVE_TRACE 0
#define DEUBG_PRINTF 0
#define STACK_DP 40960
#define NUM_INST (u_int64_t)-1

#define FILE_NAME "/home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/bubble-sort-riscv64-nemu.bin"

#if DEUBG_PRINTF
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif // DEUBG_PRINTF

static bool stopcpu = false;
void stopCPU(void)
{
  stopcpu = true;
}

//void nvboard_bind_all_pins(TOP_NAME* dut);

static VerilatedContext* contextp = new VerilatedContext;
static TOP_NAME* dut = new TOP_NAME{contextp};

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

u_int8_t mem_data[STACK_DP] = {0,};

u_int8_t mem_access(TOP_NAME* dut) {
  #define MEM_SUCCESS 0
  #define MEM_ERROR 1
  #define MEM_NOACCESS 2
  u_int64_t offset;
  if (dut->mem_r)
  {
    offset = dut->mem_addr - 0x80000000;
    if(offset <= STACK_DP){
      dut->mem_rdata = *((u_int64_t *)(mem_data+offset));
      debug_printf("load  = 0x%16lX      data = 0x%16lX      mem = 0x%16lX\n", dut->mem_addr, dut->mem_rdata, *((u_int64_t *)(mem_data+offset)));
      return MEM_SUCCESS;
    }
    else {
      debug_printf("Memory access out of bounds!\n");
      return MEM_ERROR;
    }
  }
  if (dut->mem_w)
  {
    offset = dut->mem_addr - 0x80000000;
    if(offset <= STACK_DP){
      switch (dut->mem_dlen) {
        case 0: *((u_int8_t *)(mem_data+offset)) = (u_int8_t)dut->mem_wdata;break;
        case 1: *((u_int16_t *)(mem_data+offset)) = (u_int16_t)dut->mem_wdata;break;
        case 2: *((u_int32_t *)(mem_data+offset)) = (u_int32_t)dut->mem_wdata;break;
        case 3: *((u_int64_t *)(mem_data+offset)) = (u_int64_t)dut->mem_wdata;break;
        default: break; }
      return MEM_SUCCESS;
    }
    else {
      debug_printf("Memory access out of bounds!\n");
      return MEM_ERROR;
    }
  }
  return MEM_NOACCESS;
}


u_int8_t get_inst(TOP_NAME* dut) {
  u_int64_t offset;
  offset = dut->pc - 0x80000000;
  if(offset <= STACK_DP){
    dut->inst = *((u_int32_t *)(mem_data+offset));
    return MEM_SUCCESS;
  }
  else {
    debug_printf("Memory access out of bounds!\n");
    return MEM_ERROR;
  }
}

int main(int argc,char *argv[]) {

  // nvboard_bind_all_pins(dut);
  // nvboard_init();

  IFONE(WAVE_TRACE, contextp->traceEverOn(true));
  IFONE(WAVE_TRACE, dut->trace(tfp, 0));
  IFONE(WAVE_TRACE, tfp->open("wave.vcd"));

  u_int32_t inst = 0;
  u_int64_t offset = 0;
  char filename[100];

  for (size_t i = 1; i < argc; i++)
  {
    stopcpu = false;
    strcpy(filename, "/home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/");
    strcat(filename, argv[i]);
    strcat(filename, "-riscv64-nemu.bin");

    reset(10);

    FILE *binFile = fopen(filename, "rb");
    fread(mem_data, 1, STACK_DP, binFile);
    fclose(binFile);

    dut->clk = 0;
    dut->eval();
    get_inst(dut);
    dut->eval();
    mem_access(dut);
    dut->eval();
    IFONE(WAVE_TRACE, tfp->dump(contextp->time());contextp->timeInc(1));
    while(!stopcpu)
    {
      dut->clk = 1;
      dut->eval();
      get_inst(dut);
      dut->eval();
      debug_printf("pc = 0x%16lX \t inst = 0x%08X \t dnpc = 0x%16lX\n", dut->pc, dut->inst, dut->dnpc);
      mem_access(dut);
      
      dut->eval();
      IFONE(WAVE_TRACE, tfp->dump(contextp->time());contextp->timeInc(1));
      dut->clk = 0;
      dut->eval();
      IFONE(WAVE_TRACE, tfp->dump(contextp->time());contextp->timeInc(1));
    }
    printf("CPU ebreak! pc = 0x%16lX   x10 = 0x%16lX\n", dut->pc, dut->rootp->top__DOT__u_gir__DOT____Vcellout__gir_gen__BRA__10__KET____DOT__genblk1__DOT__u_gir__dout);
  }
  IFONE(WAVE_TRACE, tfp->close());
  delete contextp;
  return 0;
}