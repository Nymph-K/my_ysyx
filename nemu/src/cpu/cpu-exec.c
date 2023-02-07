/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>
#include <cpu/ringbuf.h>
#include <elf_pars.h>
#include "../isa/riscv64/local-include/reg.h"

/* The assembly code of instructions executed is only output to the screen
 * when the number of instructions executed is less than this value.
 * This is useful when you use the `si' command.
 * You can modify this value as you want.
 */
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

static void exec_once(Decode *s, vaddr_t pc) {
  s->pc = pc;
  s->snpc = pc;
  isa_exec_once(s);
  cpu.pc = s->dnpc;
#if defined CONFIG_ITRACE || defined CONFIG_FTRACE || defined CONFIG_ETRACE
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
  #if CONFIG_ERINGBUF_DEPTH
    char etrace_log[128];
    if(strncmp(p, "ecall", 5) == 0){
      sprintf(etrace_log, "Exception-ecall: mepc = 0x%lX,  mcause = 0x%lX, mtvec = 0x%lX\n", MCSR(mepc), MCSR(mcause), MCSR(mtvec));
      ringBufWrite(&eringbuf, &etrace_log);
    }
    else if(strncmp(p, "ebreak", 6) == 0){
      sprintf(etrace_log, "Exception-ebreak: mepc = 0x%lX,  mcause = 0x%lX, mtvec = 0x%lX\n", MCSR(mepc), MCSR(mcause), MCSR(mtvec));
      ringBufWrite(&eringbuf, &etrace_log);
    }
    else if(strncmp(p, "mret", 4) == 0){
      sprintf(etrace_log, "Exception-mret: mepc = 0x%lX,  mcause = 0x%lX, mtvec = 0x%lX\n", MCSR(mepc), MCSR(mcause), MCSR(mtvec));
      ringBufWrite(&eringbuf, &etrace_log);
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

static void print_trace(void) {
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
  #if CONFIG_DRINGBUF_DEPTH
    Log("trace %d device access:", ringBufLen(&dringbuf));
    const char *dlog_str;
    while(!ringBufEmpty(&dringbuf)){
      dlog_str = ringBufRead(&dringbuf);
      _Log("%s\n", dlog_str);
    }
  #endif
  #if CONFIG_ERINGBUF_DEPTH
    Log("trace %d exceptions:", ringBufLen(&eringbuf));
    const char *elog_str;
    while(!ringBufEmpty(&eringbuf)){
      elog_str = ringBufRead(&eringbuf);
      _Log("%s\n", elog_str);
    }
  #endif
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
      print_trace();
      Log("nemu: %s at pc = " FMT_WORD,
          (nemu_state.state == NEMU_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (nemu_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          nemu_state.halt_pc);
      // fall through
    case NEMU_QUIT: statistic();
  }
}
