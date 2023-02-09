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

#include <utils.h>
#include <device/map.h>
#include "../isa/riscv64/local-include/reg.h"

static uint8_t *clint_msip_base = NULL;
static uint8_t *clint_mtimecmp_base = NULL;
static uint8_t *clint_mtime_base = NULL;
static uint64_t tick_count = 0;


static void clint_msip_io_handler(uint32_t offset, int len, bool is_write) {
  assert(len == 4);
  switch (offset) {
    case 0:
      if (is_write)
      {
        if (clint_msip_base[0] == 1)
          MCSR(mip) |= MIP_MSIP_MASK;
        else
          MCSR(mip) &= ~MIP_MSIP_MASK;
      }
      break;
    default: panic("do not support offset = %d", offset);
  }
}

static void clint_mtimecmp_io_handler(uint32_t offset, int len, bool is_write) {
  assert(len == 8);
  switch (offset) {
    case 0:
      if (is_write) MCSR(mip) &= ~MIP_MTIP_MASK;  //Writing to register clears the timer interrupt.
      break;
    default: panic("do not support offset = %d", offset);
  }
}

static void clint_mtime_io_handler(uint32_t offset, int len, bool is_write) {
  assert(len == 8);
  switch (offset) {
    case 0:
      if (is_write) tick_count = 0;
      break;
    default: panic("do not support offset = %d", offset);
  }
}

void init_clint() {
  clint_msip_base = new_space(4);
  clint_mtimecmp_base = new_space(8);
  clint_mtime_base = new_space(8);
  *(uint32_t *)clint_msip_base = 0;
  *(uint64_t *)clint_mtimecmp_base = -1;
  *(uint64_t *)clint_mtime_base = 0;
  add_mmio_map("clint msip", CONFIG_CLINT_MSIP_MMIO, clint_msip_base, 4, clint_msip_io_handler);
  add_mmio_map("clint mtimecmp", CONFIG_CLINT_MTIMECMP_MMIO, clint_mtimecmp_base, 8, clint_mtimecmp_io_handler);
  add_mmio_map("clint mtime", CONFIG_CLINT_MTIME_MMIO, clint_mtime_base, 8, clint_mtime_io_handler);
}

void clint_mtime_update(void)
{
  tick_count++;
  if (tick_count >= CONFIG_CLINT_TICK_COUNT)
  {
    tick_count = 0;
    *(uint64_t *)clint_mtime_base += 1;
    if (*(uint64_t *)clint_mtime_base >= *(uint64_t *)clint_mtimecmp_base)
    {
      MCSR(mip) |= MIP_MTIP_MASK;
    }
  }
}