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

#include <isa.h>
#include "../local-include/reg.h"

/* Trigger an interrupt/exception with ``NO''.
 * Then return the address of the interrupt/exception vector.
 */
word_t isa_raise_intr(word_t NO, vaddr_t epc) {
  MCSR(mstatus) &= ~MSTATUS_MIE_MASK;//close global interrupt enable
  MCSR(mepc) = epc;
  MCSR(mcause) = NO;
  return MCSR(mtvec);
}

void difftest_skip_ref();

word_t isa_query_intr(vaddr_t epc) {
  if((MCSR(mstatus) & MSTATUS_MIE_MASK) != 0)// global interrupt enable
  {
    if ((MCSR(mie) & (MIE_MSIE_MASK | MIE_MTIE_MASK | MIE_MEIE_MASK)) != 0)//software, timer, external interrupt enable
    {
      if ((MCSR(mip) & (MIP_MSIP_MASK | MIP_MTIP_MASK | MIP_MEIP_MASK)) != 0)//software, timer, external interrupt pending
      {
        uint64_t NO_macuse;
        if ((MCSR(mip) & MIP_MEIP_MASK) != 0)//external interrupt pending
        {
          NO_macuse = MCAUSE_INTR_MASK | MCAUSE_MEI_MASK;
        }
        else if ((MCSR(mip) & MIP_MSIP_MASK) != 0)//software interrupt pending
        {
          NO_macuse = MCAUSE_INTR_MASK | MCAUSE_MSI_MASK;
        }
        else// if (MCSR(mip) & MIP_MTIP_MASK != 0)//timer interrupt pending
        {
          NO_macuse = MCAUSE_INTR_MASK | MCAUSE_MTI_MASK;
        }
        difftest_skip_ref();
        return isa_raise_intr(NO_macuse, epc);
      }
      else return 0;
    }
    else return 0;
  }
  else return 0;
}
