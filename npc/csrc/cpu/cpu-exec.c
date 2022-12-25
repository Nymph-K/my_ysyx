#include <include.h>
#include "svdpi.h"//DPI-C
#include "Vtop__Dpi.h"//DPI-C


NPCState npc_state;

static u_int64_t halt_ret;

//void nvboard_bind_all_pins(TOP_NAME* dut);

static VerilatedContext* contextp = new VerilatedContext;
static TOP_NAME* cpu = new TOP_NAME{contextp};

#if WAVE_TRACE
#include "verilated.h"
#include "verilated_vcd_c.h"

static VerilatedVcdC* tfp = new VerilatedVcdC;

static void posedge_half_cycle() {
  cpu->clk = 1; cpu->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}
static void negedge_half_cycle() {
  cpu->clk = 0; cpu->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}

#else

static void posedge_half_cycle() {
  cpu->clk = 1; cpu->eval();
}
static void negedge_half_cycle() {
  cpu->clk = 0; cpu->eval();
}

#endif

static void single_cycle() {
  posedge_half_cycle();
  negedge_half_cycle();
}

static void reset(int n) {
  cpu->rst = 1;
  while (n -- > 0) single_cycle();
  cpu->clk = 1; cpu->eval();
  cpu->rst = 0; cpu->eval();
}

void stopCPU(void)
{
  npc_state.state = NPC_END;
}


//                 //===============\\
//---------------<||      code       ||>---------------
//                 \\===============//

#define MAX_INST_TO_PRINT 10

CPU_state cpu = {};
uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;

void device_update();

int scan_wp(void);
static void trace_and_difftest(Decode *_this, vaddr_t dnpc) {
#ifdef CONFIG_ITRACE_COND
  #if CONFIG_IRINGBUF_DEPTH
  ringBufWrite(&iringbuf, _this->logbuf);
  #else
  if (ITRACE_COND) { log_write("%s\n", _this->logbuf); }//ITRACE_COND see nemu/Makefile:line 48
  #endif
#endif
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_this->logbuf)); }
  IFDEF(CONFIG_DIFFTEST, difftest_step(_this->pc, dnpc));
#ifdef CONFIG_WATCHPOINT// 1 for c, y for makefile
  if(scan_wp()) nemu_state.state = NEMU_STOP;
#endif
}

int riscv64_exec_once(Decode *s) {
  s->isa.inst.val = inst_fetch(&cpu, 4);
  cpu->clk = 1; cpu->eval();
  get_inst(cpu);
  posedge_half_cycle();
  mem_access(cpu);
  cpu->eval();
  negedge_half_cycle();
  debug_printf("pc = 0x%16lX \t inst = 0x%08X \t dnpc = 0x%16lX\n", cpu->pc, cpu->inst, cpu->dnpc);
  return decode_exec(s);
}

static void exec_once(Decode *s, vaddr_t pc) {
  s->pc = pc;
  s->snpc = pc;
  riscv64_exec_once(s);
  cpu.pc = s->dnpc;
#ifdef CONFIG_ITRACE
  char *p = s->logbuf;
  p += snprintf(p, sizeof(s->logbuf), FMT_WORD ":", s->pc);
  int ilen = s->snpc - s->pc;
  int i;
  uint8_t *inst = (uint8_t *)&s->isa.inst.val;
  for (i = ilen - 1; i >= 0; i --) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0) space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;

  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(p, s->logbuf + sizeof(s->logbuf) - p,
      MUXDEF(CONFIG_ISA_x86, s->snpc, s->pc), (uint8_t *)&s->isa.inst.val, ilen);

  #if CONFIG_FRINGBUF_DEPTH
    callBuf cb;
    if(strncmp(p, "jalr", 4) == 0){
      cb.dnpc_fndx = is_func_start(s->dnpc | 0xffffffff00000000);
      if (cb.dnpc_fndx  != -1)
      {
        cb.c_r = 'c'; cb.pc = s->pc; cb.dnpc = s->dnpc;
        cb.pc_fndx = get_func_ndx(s->pc | 0xffffffff00000000);
        ringBufWrite(&fringbuf, &cb);
      }
    }
    else if(strncmp(p, "jal", 3) == 0){
      cb.dnpc_fndx = is_func_start(s->dnpc | 0xffffffff00000000);
      if (cb.dnpc_fndx  != -1)
      {
        cb.c_r = 'c'; cb.pc = s->pc; cb.dnpc = s->dnpc;
        cb.pc_fndx = get_func_ndx(s->pc | 0xffffffff00000000);
        ringBufWrite(&fringbuf, &cb);
      }
    }
    else if(strncmp(p, "ret", 3) == 0){
      cb.dnpc_fndx = get_func_ndx(s->dnpc | 0xffffffff00000000);
      cb.pc_fndx = get_func_ndx(s->pc | 0xffffffff00000000);
      cb.c_r = 'r'; cb.pc = s->pc; cb.dnpc = s->dnpc;
      ringBufWrite(&fringbuf, &cb);
    }
    else if(strncmp(p, "jr", 2) == 0){
      cb.dnpc_fndx = is_func_start(s->dnpc | 0xffffffff00000000);
      if (cb.dnpc_fndx  != -1)
      {
        cb.c_r = 'c'; cb.pc = s->pc; cb.dnpc = s->dnpc;
        cb.pc_fndx = get_func_ndx(s->pc | 0xffffffff00000000);
        ringBufWrite(&fringbuf, &cb);
      }
    }
  #endif
#endif
}

static void execute(uint64_t n) {
  Decode s;
  for (;n > 0; n --) {
    exec_once(&s, cpu.pc);
    g_nr_guest_inst ++;
    trace_and_difftest(&s, cpu.pc);
    if (nemu_state.state != NEMU_RUNNING) break;
    IFDEF(CONFIG_DEVICE, device_update());
  }
}

static void statistic() {
  IFNDEF(CONFIG_TARGET_AM, setlocale(LC_NUMERIC, ""));
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%ld", "%'ld")
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void assert_fail_msg() {
  isa_reg_display();
  statistic();
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n) {
  g_print_step = (n < MAX_INST_TO_PRINT);
  switch (nemu_state.state) {
    case NEMU_END: case NEMU_ABORT:
      printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
      return;
    default: nemu_state.state = NEMU_RUNNING;
  }

  uint64_t timer_start = get_time();

  execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (nemu_state.state) {
    case NEMU_RUNNING: nemu_state.state = NEMU_STOP; break;

    case NEMU_END: case NEMU_ABORT:
      #if CONFIG_IRINGBUF_DEPTH
        Log("trace %d instractions:", ringBufLen(&iringbuf));
        const char *ilog_str;
        while(!ringBufEmpty(&iringbuf)){
          ilog_str = ringBufRead(&iringbuf);
          _Log("%s\n", ilog_str);
        }
      #endif
      #if CONFIG_MRINGBUF_DEPTH
        Log("trace %d mem access:", ringBufLen(&mringbuf));
        const char *mlog_str;
        while(!ringBufEmpty(&mringbuf)){
          mlog_str = ringBufRead(&mringbuf);
          _Log("%s\n", mlog_str);
        }
      #endif
      #if CONFIG_FRINGBUF_DEPTH
        Log("trace %d function call:", ringBufLen(&fringbuf));
        callBuf *cb;
        int fun_depth = 1;
        while(!ringBufEmpty(&fringbuf)){
          cb = ringBufRead(&fringbuf);
          if(cb->c_r == 'c')
            fun_depth++;
          _Log("0x%08lx -> 0x%08lx: %s", cb->pc, cb->dnpc, cb->c_r == 'c' ? "call " : "ret  ");
          for (size_t i = 0; i < fun_depth; i++)
          {
            _Log("    ");
          }
          if(cb->c_r == 'c')
            _Log("%s -> %s\n", get_func_name_ndx(cb->pc_fndx), get_func_name_ndx(cb->dnpc_fndx));
          else
            _Log("%s <- %s\n", get_func_name_ndx(cb->dnpc_fndx), get_func_name_ndx(cb->pc_fndx));
          
          if(cb->c_r == 'r')
            fun_depth = fun_depth == 0 ? 0 : fun_depth - 1;
        }
      #endif
      Log("nemu: %s at pc = " FMT_WORD,
          (nemu_state.state == NEMU_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (nemu_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          nemu_state.halt_pc);
      // fall through
    case NEMU_QUIT: statistic();
  }
}
