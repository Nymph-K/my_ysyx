#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>
#include <cpu/ringbuf.h>
#include <elf_pars.h>
#include "../isa/riscv64/local-include/reg.h"

#pragma GCC diagnostic ignored "-Wunused-variable"

#define MAX_INST_TO_PRINT 10

uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;

void device_update();

int scan_wp(void);
bool scan_bp(char *fname);

static char *funcName = NULL;

static void trace_and_difftest(Decode *_this, vaddr_t dnpc) {
#ifdef CONFIG_ITRACE_COND
  #if CONFIG_IRINGBUF_DEPTH
  if(enable_ringbuf) ringBufWrite(&iringbuf, _this->logbuf);
  #else
  if (ITRACE_COND) { log_write("%s\n", _this->logbuf); }//ITRACE_COND see npc/Makefile:line 48
  #endif
#endif
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_this->logbuf)); }
  IFDEF(CONFIG_DIFFTEST, difftest_step(_this->pc, dnpc));
#ifdef CONFIG_WATCHPOINT// 1 for c, y for makefile
  if(scan_wp()) npc_state.state = NPC_STOP;
#endif
#ifdef CONFIG_BREAKPOINT// 1 for c, y for makefile
  if(funcName && scan_bp(funcName)) {
    funcName = NULL;
    npc_state.state = NPC_STOP;
  }
#endif
}

static void exec_once(Decode *s) {
  isa_exec_once(s);
#if CONFIG_ITRACE || CONFIG_FTRACE || CONFIG_ETRACE || CONFIG_BREAKPOINT
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

  #if CONFIG_FTRACE || CONFIG_BREAKPOINT
    callBuf cb = {.pc_elf_idx = -1, .pc_sym_idx = -1, .dnpc_elf_idx = -1, .dnpc_sym_idx = -1};

    if((strncmp(p, "jalr", 4) == 0) || 
       (strncmp(p, "jal", 3) == 0)  ||
       (strncmp(p, "jr", 2) == 0)  ||
       (strncmp(p, "j", 1) == 0)){
      cb.dnpc_sym_idx = is_func_start(s->dnpc, &cb.dnpc_elf_idx);
      if (cb.dnpc_sym_idx  != -1)
      {
          cb.c_r = 'c'; cb.pc = s->pc; cb.dnpc = s->dnpc;
          cb.pc_sym_idx = get_func_ndx(s->pc, &cb.pc_elf_idx);
          // if(trace_print)
          //   printf("call :%s ->> %s\n", get_func_name_by_idx(cb.pc_sym_idx, cb.pc_elf_idx), get_func_name_by_idx(cb.dnpc_sym_idx, cb.dnpc_elf_idx));
          #if CONFIG_FRINGBUF_DEPTH
          if(enable_ringbuf){
            ringBufWrite(&fringbuf, &cb);
          }
          #endif
          #ifdef CONFIG_BREAKPOINT
            funcName = get_func_name_by_idx(cb.dnpc_sym_idx, cb.dnpc_elf_idx);
          #endif
      }
    }
    else if(strncmp(p, "ret", 3) == 0){
        cb.dnpc_sym_idx = get_func_ndx(s->dnpc, &cb.dnpc_elf_idx);
        cb.pc_sym_idx = get_func_ndx(s->pc, &cb.pc_elf_idx);
        cb.c_r = 'r'; cb.pc = s->pc; cb.dnpc = s->dnpc;
        // if(trace_print)
        //   printf("ret  :%s <<- %s\n", get_func_name_by_idx(cb.pc_sym_idx, cb.pc_elf_idx), get_func_name_by_idx(cb.dnpc_sym_idx, cb.dnpc_elf_idx));
        #if CONFIG_FRINGBUF_DEPTH
          if(enable_ringbuf){
              ringBufWrite(&fringbuf, &cb);
          }
        #endif
    }
  #endif
  #if CONFIG_ERINGBUF_DEPTH
    char etrace_log[128];
    if(strncmp(p, "ecall", 5) == 0){
      if(enable_ringbuf){
        sprintf(etrace_log, "Exception-ecall: mepc = %lx,  mcause= %lx, mtvec = %lx\n", csr[9], csr[10], csr[5]);
        ringBufWrite(&eringbuf, &etrace_log);
      }
    }
    else if(strncmp(p, "ebreak", 6) == 0){
      if(enable_ringbuf){
        sprintf(etrace_log, "Exception-ebreak: mepc = %lx,  mcause= %lx, mtvec = %lx\n", csr[9], csr[10], csr[5]);
        ringBufWrite(&eringbuf, &etrace_log);
      }
    }
    else if(strncmp(p, "mret", 4) == 0){
      if(enable_ringbuf){
        sprintf(etrace_log, "Exception-mret: mepc = %lx,  mcause= %lx, mtvec = %lx\n", csr[9], csr[10], csr[5]);
        ringBufWrite(&eringbuf, &etrace_log);
      }
    }
  #endif
#endif
}

#define is_interrupt mycpu->rootp->top__DOT__u_exu__DOT__interrupt
static void execute(uint64_t n) {
  Decode s;
  for (;n > 0; n --) {
    exec_once(&s);
    g_nr_guest_inst ++;
    IFDEF(CONFIG_DIFFTEST, if(is_interrupt) difftest_skip_ref());
    trace_and_difftest(&s, mycpu->dnpc);
    if (npc_state.state != NPC_RUNNING) break;
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

static void print_trace(void) {
  #if CONFIG_IRINGBUF_DEPTH
    Log("trace %d instractions:", ringBufLen(&iringbuf));
    const char *ilog_str;
    while(!ringBufEmpty(&iringbuf)){
      ilog_str = (char *)ringBufRead(&iringbuf);
      _Log("%s\n", ilog_str);
    }
  #endif
  #if CONFIG_MRINGBUF_DEPTH
    Log("trace %d mem access:", ringBufLen(&mringbuf));
    const char *mlog_str;
    while(!ringBufEmpty(&mringbuf)){
      mlog_str = (char *)ringBufRead(&mringbuf);
      _Log("%s\n", mlog_str);
    }
  #endif
  #if CONFIG_FRINGBUF_DEPTH
    Log("trace %d function call:", ringBufLen(&fringbuf));
    callBuf *cb;
    int fun_depth = 1;
    while(!ringBufEmpty(&fringbuf)){
      cb = (callBuf *)ringBufRead(&fringbuf);
      if(cb->c_r == 'c')
        fun_depth++;
      _Log("0x%08lx -> 0x%08lx: %s", cb->pc, cb->dnpc, cb->c_r == 'c' ? "call " : "ret  ");
      for (size_t i = 0; i < fun_depth; i++)
      {
        _Log("    ");
      }
      if(cb->c_r == 'c')
        _Log("%s -> %s\n", get_func_name_by_idx(cb->pc_sym_idx, cb->pc_elf_idx), get_func_name_by_idx(cb->dnpc_sym_idx, cb->dnpc_elf_idx));
      else
        _Log("%s <- %s\n", get_func_name_by_idx(cb->dnpc_sym_idx, cb->dnpc_elf_idx), get_func_name_by_idx(cb->pc_sym_idx, cb->pc_elf_idx));
      
      if(cb->c_r == 'r')
        fun_depth = fun_depth == 0 ? 0 : fun_depth - 1;
    }
  #endif
  #if CONFIG_DRINGBUF_DEPTH
    Log("trace %d device access:", ringBufLen(&dringbuf));
    const char *dlog_str;
    while(!ringBufEmpty(&dringbuf)){
      dlog_str = (char *)ringBufRead(&dringbuf);
      _Log("%s\n", dlog_str);
    }
  #endif
  #if CONFIG_ERINGBUF_DEPTH
    Log("trace %d exceptions:", ringBufLen(&eringbuf));
    const char *elog_str;
    while(!ringBufEmpty(&eringbuf)){
      elog_str = (char *)ringBufRead(&eringbuf);
      _Log("%s\n", elog_str);
    }
  #endif
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n) {
  g_print_step = (n < MAX_INST_TO_PRINT);
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  uint64_t timer_start = get_time();

  execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;

    case NPC_END: case NPC_ABORT:
      print_trace();
      Log("npc: %s at pc = " FMT_WORD,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          npc_state.halt_pc);
      // fall through
    
    case NPC_QUIT: statistic();
  }
}