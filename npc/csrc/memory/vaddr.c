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

#include <isa.h>
#include <memory/paddr.h>
#include <memory/host.h>

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, (paddr_t)CONFIG_MBASE, (paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1, mycpu->pc);
}

word_t vaddr_ifetch(vaddr_t addr, int len) {
  if (likely(in_pmem(addr)))
  {
    return host_read(guest_to_host(addr), len);
  }
  else
  {
    out_of_bound(addr);
    return 0;
  }
}

word_t vaddr_read(vaddr_t addr, int len) {
  long long  rdata;
  paddr_read(addr, &rdata);
  return rdata;
}

void vaddr_write(vaddr_t addr, int len, word_t data) {
  vaddr_t waddr = addr & ~0x7ull;
  uint8_t wmask;
  switch (len)
  {
    case 1: wmask = 1; break;
    case 2: wmask = 3; break;
    case 4: wmask = 15; break;
    case 8: wmask = 255; break;
    default:wmask = 255; break;
  }
  wmask = wmask << (addr & 0x7ull);
  paddr_write(waddr, data, wmask);
}
