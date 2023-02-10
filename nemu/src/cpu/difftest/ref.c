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
#include <cpu/cpu.h>
#include <difftest-def.h>
#include <memory/paddr.h>
#include "../../isa/riscv64/local-include/reg.h"

void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction) {
  if (direction == DIFFTEST_TO_REF) {
    for (size_t i = 0; i < n; i++)
    {
      paddr_write(addr + i, 1, ((uint8_t *)buf)[i]);
    }
  } else {
    for (size_t i = 0; i < n; i++)
    {
      ((uint8_t *)buf)[i] = paddr_read(addr + i, 1);
    }
  }
}

typedef struct {
  vaddr_t pc;
  word_t gpr[32];
  word_t mcsr[15];
} npc_riscv64_CPU_state;

void difftest_regcpy(void *dut, bool direction) {
  if (direction == DIFFTEST_TO_REF) {
    for (size_t i = 0; i < 32; i++)
    {
      cpu.gpr[i] = ((npc_riscv64_CPU_state *)dut)->gpr[i];
    }
    {
      mcsr[0x00] = ((npc_riscv64_CPU_state *)dut)->mcsr[0];
      mcsr[0x01] = ((npc_riscv64_CPU_state *)dut)->mcsr[1];
      mcsr[0x02] = ((npc_riscv64_CPU_state *)dut)->mcsr[2];
      mcsr[0x03] = ((npc_riscv64_CPU_state *)dut)->mcsr[3];
      mcsr[0x04] = ((npc_riscv64_CPU_state *)dut)->mcsr[4];
      mcsr[0x05] = ((npc_riscv64_CPU_state *)dut)->mcsr[5];
      mcsr[0x06] = ((npc_riscv64_CPU_state *)dut)->mcsr[6];
      mcsr[0x10] = ((npc_riscv64_CPU_state *)dut)->mcsr[7];
      mcsr[0x40] = ((npc_riscv64_CPU_state *)dut)->mcsr[8];
      mcsr[0x41] = ((npc_riscv64_CPU_state *)dut)->mcsr[9];
      mcsr[0x42] = ((npc_riscv64_CPU_state *)dut)->mcsr[10];
      mcsr[0x43] = ((npc_riscv64_CPU_state *)dut)->mcsr[11];
      mcsr[0x44] = ((npc_riscv64_CPU_state *)dut)->mcsr[12];
      mcsr[0x4A] = ((npc_riscv64_CPU_state *)dut)->mcsr[13];
      mcsr[0x4B] = ((npc_riscv64_CPU_state *)dut)->mcsr[14];
    }
    cpu.pc = ((npc_riscv64_CPU_state *)dut)->pc;
  } else {
    for (size_t i = 0; i < 32; i++)
    {
      ((npc_riscv64_CPU_state *)dut)->gpr[i] = cpu.gpr[i];
    }
    ((npc_riscv64_CPU_state *)dut)->pc = cpu.pc;
  }
}

void difftest_exec(uint64_t n) {
  cpu_exec(n);
}

word_t isa_raise_intr(word_t NO, vaddr_t epc);

void difftest_raise_intr(word_t NO) {
  cpu.pc = isa_raise_intr(NO, cpu.pc);
}

void difftest_init(int port) {
  /* Perform ISA dependent initialization. */
  init_isa();
}
