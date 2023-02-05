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

#include <memory/paddr.h>

word_t vaddr_ifetch(vaddr_t addr, int len) {
  long long  inst;
  paddr_read(addr, &inst);
  return inst;
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
