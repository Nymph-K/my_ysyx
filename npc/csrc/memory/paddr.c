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

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>
#include <cpu/ringbuf.h>

#include "svdpi.h"//DPI-C
#include "Vtop__Dpi.h"//DPI-C

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  #if CONFIG_MRINGBUF_DEPTH
    if(enable_ringbuf){
      char str[128];
      sprintf(str, "Read : Mem[ " FMT_PADDR " ] = " FMT_WORD "\tlen = %d", addr, ret, len);
      ringBufWrite(&mringbuf, str);
    }
  #endif
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
  #if CONFIG_MRINGBUF_DEPTH
    if(enable_ringbuf){
      char str[128];
      sprintf(str, "Write: Mem[ " FMT_PADDR " ] = " FMT_WORD "\tlen = %d", addr, data, len);
      ringBufWrite(&mringbuf, str);
    }
  #endif
}

static void out_of_bound(paddr_t addr) {
  #if OUT_BOUND_CONTINUE
    printf(ANSI_FMT("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD "\n", ANSI_FG_RED),
      addr, (paddr_t)CONFIG_MBASE, (paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1, mycpu->pc);
    void set_npc_state(int state, vaddr_t pc, int halt_ret);
    set_npc_state(NPC_ABORT, mycpu->pc, -1);
  #else
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, (paddr_t)CONFIG_MBASE, (paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1, mycpu->pc);
  #endif
}

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
#ifdef CONFIG_MEM_RANDOM
  uint32_t *p = (uint32_t *)pmem;
  int i;
  for (i = 0; i < (int) (CONFIG_MSIZE / sizeof(p[0])); i ++) {
    p[i] = rand();
  }
#endif
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]",
      (paddr_t)CONFIG_MBASE, (paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1);
}

extern "C" void instruction_fetch(long long  pc, int *inst) {
    if (likely(in_pmem(pc))){
      *inst = host_read(guest_to_host(pc), 4);
    }
    else{
      out_of_bound(pc);
      *inst = 0;
    }
}

#if ADDR_ALIGN
extern "C" void paddr_read(long long raddr, long long *rdata) {
  // 总是读取地址为`raddr & ~0x7ull`的8字节返回给`rdata`
  paddr_t addr = raddr & ~0x7ull;
  if (likely(in_pmem(addr))) {
    *rdata = pmem_read(addr, 8);
    return;
  }
  #ifdef CONFIG_DEVICE
  *rdata = mmio_read(addr, 8);
  return;
  #endif
  // else if(addr == CLINT_MSIP_ADDR || addr == CLINT_MTIME_ADDR || addr == CLINT_MTIMECMP_ADDR)
  // {
  //   #ifdef CONFIG_DIFFTEST
  //     difftest_skip_ref();
  //   #endif
  // }
  out_of_bound(addr);
}

extern "C" void paddr_write(long long waddr, long long wdata, char wmask) {
  // 总是往地址为`waddr & ~0x7ull`的8字节按写掩码`wmask`写入`wdata`
  // `wmask`中每比特表示`wdata`中1个字节的掩码,
  // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
  paddr_t addr = waddr & ~0x7ull;
  size_t off, len;
  for (off = 0; off < 8; off++)
  {
    if ((wmask & 1) == 0)
    {
      wmask = (unsigned char)wmask >> 1;
      wdata = (uint64_t)wdata >> 8;
    }
    else break;
  }
  switch ((unsigned char)wmask)
  {
    case 1: len = 1; break;
    case 3: len = 2; break;
    case 15: len = 4; break;
    case 255: len = 8; break;
    default: len = 0; break;
  }
  if (likely(in_pmem(addr))) { 
    pmem_write(addr + off, len, wdata);
    return;
  }
  #ifdef CONFIG_DEVICE
  mmio_write(addr + off, len, wdata);
  return;
  #endif
  // else if(addr == CLINT_MSIP_ADDR || addr == CLINT_MTIME_ADDR || addr == CLINT_MTIMECMP_ADDR)
  // {
  //   #ifdef CONFIG_DIFFTEST
  //     difftest_skip_ref();
  //   #endif
  // }
  out_of_bound(addr);
}
#else//ADDR_ALIGN
extern "C" void paddr_read(long long addr, long long *rdata) {
  if (likely(in_pmem(addr))) {
    *rdata = pmem_read(addr, 8);
    return;
  }
  #ifdef CONFIG_DEVICE
  *rdata = mmio_read(addr, 8);
  return;
  #endif
  // else if(addr == CLINT_MSIP_ADDR || addr == CLINT_MTIME_ADDR || addr == CLINT_MTIMECMP_ADDR)
  // {
  //   #ifdef CONFIG_DIFFTEST
  //     difftest_skip_ref();
  //   #endif
  // }
  out_of_bound(addr);
  *rdata = 0;
}

extern "C" void paddr_write(long long addr, long long wdata, char wmask) {
  size_t len = wmask;
  if (likely(in_pmem(addr))) { 
    pmem_write(addr, len, wdata);
    return;
  }
  #ifdef CONFIG_DEVICE
  mmio_write(addr, len, wdata);
  return;
  #endif
  // else if(addr == CLINT_MSIP_ADDR || addr == CLINT_MTIME_ADDR || addr == CLINT_MTIMECMP_ADDR)
  // {
  //   #ifdef CONFIG_DIFFTEST
  //     difftest_skip_ref();
  //   #endif
  // }
  out_of_bound(addr);
}

#endif//ADDR_ALIGN