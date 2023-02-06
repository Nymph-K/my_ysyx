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

#ifndef __RISCV64_REG_H__
#define __RISCV64_REG_H__

#include <common.h>

typedef enum {
  mstatus     = 0x300,
  misa        = 0x301,
  medeleg     = 0x302,
  mideleg     = 0x303,
  mie         = 0x304,
  mtvec       = 0x305,
  mcounteren  = 0x306,
  mstatush    = 0x310,
  mscratch    = 0x340,
  mepc        = 0x341,
  mcause      = 0x342,
  mtval       = 0x343,
  mip         = 0x344,
  mtinst      = 0x34A,
  mtval2      = 0x34B
} mcsr_idx;

extern uint64_t mcsr[128];

#define MCSR(idx) (mcsr[check_csr_idx(idx)])

static inline int check_csr_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= mstatus && idx < mtval2));
  return (idx & 0xFF);
}

static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 32));
  return idx;
}

#define gpr(idx) (cpu.gpr[check_reg_idx(idx)])

static inline const char* reg_name(int idx, int width) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}

#endif
