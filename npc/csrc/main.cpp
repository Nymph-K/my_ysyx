#include "include.h"



int main(int argc,char *argv[]) {

  init_monitor(argc, argv);
  // nvboard_bind_all_pins(cpu);
  // nvboard_init();

#if WAVE_TRACE
  contextp->traceEverOn(true);
  cpu->trace(tfp, 0);
  tfp->open("wave.vcd");
#endif

  for (size_t i = 1; i < argc; i++)
  {
    if(load_bin(argv[i]) != 0) continue;
    printf("[%14s]\n", base_name);
    reset(10); cpu->eval(); get_inst(cpu);
    stopcpu = false;
    while(!stopcpu)
    {
      cpu->clk = 1; cpu->eval();
      get_inst(cpu);
      posedge_half_cycle();
      mem_access(cpu);
      cpu->eval();
      negedge_half_cycle();
      debug_printf("pc = 0x%16lX \t inst = 0x%08X \t dnpc = 0x%16lX\n", cpu->pc, cpu->inst, cpu->dnpc);
    }
    halt_ret = GPR(10);
    printf("\t\tNPC ebreak at pc = " FMT_WORD " \t%s\n", cpu->pc, (halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) : ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED)));
  }
  //IFWAVE(tfp->close());
  delete contextp;
  return halt_ret;
}