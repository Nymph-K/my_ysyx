#ifndef __INCLUDE_H__
#define __INCLUDE_H__

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include <unistd.h>

#include "macro.h"

#include <Vtop.h>
#include "Vtop___024root.h"//dut->rootp

// ----------- Nvboard use -----------
#define NVBOARD_USE 0
#if NVBOARD_USE
#include <nvboard.h>
#endif

// ----------- type -----------
typedef uint64_t word_t;
typedef int64_t sword_t;
typedef word_t vaddr_t;
typedef uint64_t paddr_t;
typedef uint16_t ioaddr_t;

// ----------- npc state -----------
enum __NPC_STATE__ { NPC_RUNNING, NPC_STOP, NPC_END, NPC_ABORT, NPC_QUIT };
typedef struct {
  enum __NPC_STATE__ state;
  vaddr_t halt_pc;
  uint32_t halt_ret;
} NPCState;
extern NPCState npc_state;

extern TOP_NAME* cpu

// ----------- ram 128MB -----------
#define STACK_DP 0x8000000
// ----------- timer -----------
//uint64_t get_time();


// ----------- wave trace -----------
#define WAVE_TRACE 0
#if WAVE_TRACE
#define IFWAVE(...) do{__VA_ARGS__;}while(0)
#else
#define IFWAVE(...)
#endif // WAVE_TRACE

// ----------- debug print -----------
#define DEUBG_PRINT 0
#if DEUBG_PRINT
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif // DEUBG_PRINTF

// ----------- log -----------
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

#define FMT_WORD "0x%016lX"
#define FMT_PADDR "0x%016lX"
#define ANSI_FMT(str, fmt) fmt str ANSI_NONE

#define log_write(...) IFDEF(CONFIG_TARGET_NATIVE_ELF, \
  do { \
    extern FILE* log_fp; \
    extern bool log_enable(); \
    if (log_enable()) { \
      fprintf(log_fp, __VA_ARGS__); \
      fflush(log_fp); \
    } \
  } while (0) \
)

#define _Log(...) \
  do { \
    printf(__VA_ARGS__); \
    log_write(__VA_ARGS__); \
  } while (0)


// ----------- cpu.gpr -----------
#define GPR(n) dut->rootp->top__DOT__u_gir__DOT____Vcellout__gir_gen__BRA__##n##__KET____DOT__genblk1__DOT__u_gir__dout

#endif /*__INCLUDE_H__*/