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

#define DPI_C_SET_GPR_PTR 1
#define GPR(n) mycpu->rootp->top__DOT__u_gir__DOT____Vcellout__gir_gen__BRA__##n##__KET____DOT__genblk1__DOT__u_gir__dout
#define gpr(n) *((uint64_t *)&(GPR(0)) + n)//mycpu->rootp->top__DOT__u_gir__DOT__gir->m_storage
#define csr mycpu->rootp->top__DOT__u_exu__DOT__u_csr__DOT__mcsr

static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 32));
  return idx;
}

static inline const char* reg_name(int idx, int width) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}

extern uint64_t *cpu_gpr;

void isa_reg_display(void);
word_t isa_reg_str2val(const char *s, bool *success);

#endif
