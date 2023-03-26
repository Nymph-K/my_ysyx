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


#include "local-include/reg.h"
#include <isa.h>

#if DPI_C_SET_GPR_PTR
#include "verilated_dpi.h"
uint64_t *cpu_gpr = NULL;
extern "C" void set_gpr_ptr(const svOpenArrayHandle r) {
  cpu_gpr = (uint64_t *)(((VerilatedDpiOpenVar*)r)->datap());
}
#else
#include <Vtop___024root.h>
uint64_t *cpu_gpr = (uint64_t *)&(mycpu->rootp->top__DOT__u_gir__DOT__gir);
#endif

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void isa_reg_display() {
  for (int i = 0; i < 32; i++)
  {
    printf("%-3s = 0x%-20lx", regs[i], cpu_gpr[i]);
    if((i + 1)%4 == 0) printf("\n");
  }
}

word_t isa_reg_str2val(const char *s, bool *success) {
  if(strcmp(s, "0") == 0 || strcmp(s, regs[0]) == 0) // $0 || $$0
  {
    *success = true;
    return 0;
  }
  if (strcmp(s, "pc") == 0)
  {
    *success = true;
    return mycpu->pc;
  }
  for (int i = 1; i < 32; i++)
  {
    if(strcmp(s, regs[i]) == 0) 
    {
      *success = true;
      return cpu_gpr[i];
    }
  }
  *success = false;
  return -1;
}

void reg_copy_to(CPU_state *ref)
{
  for (int i = 0; i < 32; i++)
  {
    ref->gpr[i] = cpu_gpr[i];
  }
  for (size_t i = 0; i < 15; i++)
  {
    ref->mcsr[i] = csr[i];
  }
  ref->pc = mycpu->pc;
}

void reg_set_from(CPU_state *ref)
{
  for (int i = 0; i < 32; i++)
  {
    cpu_gpr[i] = ref->gpr[i];
  }
  mycpu->pc = ref->pc;
}