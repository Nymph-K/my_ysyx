//#include <nvboard.h>
#include <Vtop.h>
#include "svdpi.h"//DPI-C
#include "Vtop__Dpi.h"//DPI-C
#include "Vtop___024root.h"//dut->rootp
#include <stdio.h>
#include <stdlib.h>
//#include </home/k/ysyx-workbench/nemu/include/macro.h>//IFDEF

#define WAVE_TRACE 0
#define DEUBG_PRINTF 0
#define STACK_DP 40960
#define NUM_INST (u_int64_t)-1

#if WAVE_TRACE
#define IFWAVE(...) do{__VA_ARGS__;}while(0)
#else
#define IFWAVE(...)
#endif // WAVE_TRACE

#if DEUBG_PRINTF
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif // DEUBG_PRINTF

#define ANSI_FG_BLACK   "\33[1;30m"
#define ANSI_FG_RED     "\33[1;31m"
#define ANSI_FG_GREEN   "\33[1;32m"
#define ANSI_FG_YELLOW  "\33[1;33m"
#define ANSI_FG_BLUE    "\33[1;34m"
#define ANSI_FG_MAGENTA "\33[1;35m"
#define ANSI_FG_CYAN    "\33[1;36m"
#define ANSI_FG_WHITE   "\33[1;37m"
#define ANSI_BG_BLACK   "\33[1;40m"
#define ANSI_BG_RED     "\33[1;41m"
#define ANSI_BG_GREEN   "\33[1;42m"
#define ANSI_BG_YELLOW  "\33[1;43m"
#define ANSI_BG_BLUE    "\33[1;44m"
#define ANSI_BG_MAGENTA "\33[1;35m"
#define ANSI_BG_CYAN    "\33[1;46m"
#define ANSI_BG_WHITE   "\33[1;47m"
#define ANSI_NONE       "\33[0m"

#define ANSI_FMT(str, fmt) fmt str ANSI_NONE
#define FMT_WORD "0x%016lX"
#define FMT_PADDR "0x%016lX"

#define GPR(n) dut->rootp->top__DOT__u_gir__DOT____Vcellout__gir_gen__BRA__##n##__KET____DOT__genblk1__DOT__u_gir__dout

static bool stopcpu = false;
static u_int64_t halt_ret;
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

static void posedge_half_cycle() {
  dut->clk = 1; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}
static void negedge_half_cycle() {
  dut->clk = 0; dut->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}

#else

static void posedge_half_cycle() {
  dut->clk = 1; dut->eval();
}
static void negedge_half_cycle() {
  dut->clk = 0; dut->eval();
}

#endif

static void single_cycle() {
  posedge_half_cycle();
  negedge_half_cycle();
}

static void reset(int n) {
  dut->rst = 1;
  while (n -- > 0) single_cycle();
  dut->clk = 1; dut->eval();
  dut->rst = 0; dut->eval();
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

char base_name[50];//base_name: dummy
char abso_name[100];//Absolute path
int load_bin(char *bin_file){
  FILE *binFile = NULL;
  if(bin_file[0] == '/'){
    //Absolute path: /home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/dummy-riscv64-npc.bin
    strcpy(abso_name, bin_file);
    strcpy(base_name, strrchr(bin_file, '/')+1);
    size_t j = strlen(base_name) - 16;
    base_name[j] = '\0';
  } else {
    // base_name: dummy
    strcpy(base_name, bin_file);
    strcpy(abso_name, "/home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/");
    strcat(abso_name, bin_file);
    strcat(abso_name, "-riscv64-npc.bin");
  }
  binFile = fopen(abso_name, "rb");
  if(binFile != NULL){
    fread(mem_data, 1, STACK_DP, binFile);
    fclose(binFile);
    return 0;
  }else{
    printf("NO such file: %s !\n", abso_name);
    fclose(binFile);
    return 1;
  }
}

int main(int argc,char *argv[]) {

  // nvboard_bind_all_pins(dut);
  // nvboard_init();

#if WAVE_TRACE
  contextp->traceEverOn(true);
  dut->trace(tfp, 0);
  tfp->open("wave.vcd");
#endif

  u_int32_t inst = 0;
  u_int64_t offset = 0;

  for (size_t i = 1; i < argc; i++)
  {
    if(load_bin(argv[i]) != 0) continue;
    printf("[%14s]\n", base_name);
    reset(10); dut->eval(); get_inst(dut);
    stopcpu = false;
    while(!stopcpu)
    {
      dut->clk = 1; dut->eval();
      get_inst(dut);
      posedge_half_cycle();
      mem_access(dut);
      dut->eval();
      negedge_half_cycle();
      debug_printf("pc = 0x%16lX \t inst = 0x%08X \t dnpc = 0x%16lX\n", dut->pc, dut->inst, dut->dnpc);
    }
    halt_ret = GPR(10);
    printf("\t\tNPC ebreak at pc = " FMT_WORD " \t%s\n", dut->pc, (halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) : ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED)));
  }
  //IFWAVE(tfp->close());
  delete contextp;
  return halt_ret;
}