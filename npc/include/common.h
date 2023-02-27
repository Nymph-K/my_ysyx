#ifndef __NPC_COMMON_H__
#define __NPC_COMMON_H__

#include "Vtop.h"
#include "Vtop___024root.h"//dut->rootp

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

#include "/home/k/ysyx-workbench/nemu/include/generated/autoconf.h"
#include "macro.h"


#ifdef CONFIG_TARGET_AM
#include <klib.h>
#else
#include <assert.h>
#include <stdlib.h>
#endif


// ----------- Nvboard use -----------
#define NVBOARD_USE 0
#if NVBOARD_USE
#include <nvboard.h>
#endif

// ----------- ram 128MB -----------
#define STACK_DP 0x8000000

// ----------- timer -----------
#define TIMER_HZ 60
uint64_t get_time();

// ----------- wave trace -----------
#define WAVE_TRACE 0
#if WAVE_TRACE
#define IFWAVE(...) do{__VA_ARGS__;}while(0)
#else
#define IFWAVE(...)
#endif // WAVE_TRACE

// ----------- use nvboard -----------
#define USE_NVBOARD 0
#if USE_NVBOARD
#define IFNVBOARD(...) do{__VA_ARGS__;}while(0)
#else
#define IFNVBOARD(...)
#endif // USE_NVBOARD

// ----------- debug print -----------
#define DEUBG_PRINT 0
#if DEUBG_PRINT
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif // DEUBG_PRINTF


// ----------- diff test -----------
enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
# define DIFFTEST_REG_SIZE (sizeof(uint64_t) * 33) // GRPs + pc

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

#define PMEM64 1
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

#define Log(format, ...) \
    _Log(ANSI_FMT("[%s:%d %s] " format, ANSI_FG_BLUE) "\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)

#define Assert(cond, format, ...) \
  do { \
    if (!(cond)) { \
      MUXDEF(CONFIG_TARGET_AM, printf(ANSI_FMT(format, ANSI_FG_RED) "\n", ## __VA_ARGS__), \
        (fflush(stdout), fprintf(stderr, ANSI_FMT(format, ANSI_FG_RED) "\n", ##  __VA_ARGS__))); \
      IFNDEF(CONFIG_TARGET_AM, extern FILE* log_fp; fflush(log_fp)); \
      extern void assert_fail_msg(); \
      assert_fail_msg(); \
      assert(cond); \
    } \
  } while (0)

#define panic(format, ...) Assert(0, format, ## __VA_ARGS__)

#define TODO() panic("please implement me")

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

// ----------- cpu state -----------
typedef struct {
  vaddr_t pc;
  word_t gpr[32];
  word_t mcsr[15];
} riscv64_CPU_state;
#define CPU_state riscv64_CPU_state

// ----------- Decode -----------
typedef struct {
  union {
    uint32_t val;
  } inst;
} riscv64_ISADecodeInfo;

typedef struct {
  vaddr_t pc;
  vaddr_t snpc; // static next pc
  vaddr_t dnpc; // dynamic next pc
  riscv64_ISADecodeInfo isa;
  char logbuf[128];//IFDEF(CONFIG_ITRACE, logbuf[128])
} Decode;



// ----------- extern variables -----------
extern NPCState npc_state;
extern TOP_NAME* mycpu;
extern bool disable_diff;
extern bool enable_ringbuf;
extern bool trace_print;

#endif /* __NPC_COMMON_H__ */