/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NPC is licensed under Mulan PSL v2.
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

#ifndef __NPC_COMMON_H__
#define __NPC_COMMON_H__

#include "Vtop.h"
#include "Vtop___024root.h"//dut->rootp

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

//#include <generated/autoconf.h>
#include <macro.h>

#ifdef CONFIG_TARGET_AM
#include <klib.h>
#else
#include <assert.h>
#include <stdlib.h>
#endif

#include "/home/k/ysyx-workbench/nemu/include/generated/autoconf.h"

#if CONFIG_MBASE + CONFIG_MSIZE > 0x100000000ul
#define PMEM64 1
#endif

typedef MUXDEF(CONFIG_ISA64, uint64_t, uint32_t) word_t;
typedef MUXDEF(CONFIG_ISA64, int64_t, int32_t)  sword_t;
#define FMT_WORD MUXDEF(CONFIG_ISA64, "0x%016lx", "0x%08x")

typedef word_t vaddr_t;
typedef MUXDEF(PMEM64, uint64_t, uint32_t) paddr_t;
#define FMT_PADDR MUXDEF(PMEM64, "0x%016lx", "0x%08x")
typedef uint16_t ioaddr_t;

#include <debug.h>

// ----------- use AXI IFU -----------
#define USE_AXI_IFU         1

// ----------- use AXI LSU -----------
#define USE_AXI_LSU         1

// ----------- wave trace -----------
#define WAVE_TRACE          1
#if WAVE_TRACE
#define IFWAVE(...) do{__VA_ARGS__;}while(0)
#else
#define IFWAVE(...)
#endif

// ----------- addr 8 bit align -----------
#define ADDR_ALIGN          1

// ----------- out of bound -----------
#define OUT_BOUND_CONTINUE  1

// ----------- Nvboard use -----------
#define NVBOARD_USE         0
#if NVBOARD_USE
#include <nvboard.h>
#endif

// ----------- ram 128MB -----------
#define STACK_DP 0x8000000

// ----------- use nvboard -----------
#define USE_NVBOARD         0
#if USE_NVBOARD
#define IFNVBOARD(...) do{__VA_ARGS__;}while(0)
#else
#define IFNVBOARD(...)
#endif

// ----------- debug print -----------
#define DEUBG_PRINT         0
#if DEUBG_PRINT
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif

#ifndef __GUEST_ISA__
#define __GUEST_ISA__ riscv64
#endif

// ----------- extern variables -----------
extern TOP_NAME *mycpu;
extern bool disable_diff;
extern bool enable_ringbuf;
extern bool trace_print;

#ifndef CONFIG_TRACE_START
#define CONFIG_TRACE_START 0
#endif

#ifndef CONFIG_TRACE_END
#define CONFIG_TRACE_END -1
#endif

#endif /* __NPC_COMMON_H__ */