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

#include <memory/host.h>
#include <memory/paddr.h>
//#include <device/mmio.h>
#include <ringbuf.h>

#include "svdpi.h"//DPI-C
#include "Vtop__Dpi.h"//DPI-C

#include <stdio.h>
#include <sys/time.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

void difftest_skip_ref();

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  #if CONFIG_MRINGBUF_DEPTH
    char str[128];
    sprintf(str, "Read : Mem[ " FMT_PADDR " ] = " FMT_WORD "\tlen = %d", addr, ret, len);
    ringBufWrite(&mringbuf, str);
  #endif
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
  #if CONFIG_MRINGBUF_DEPTH
    char str[128];
    sprintf(str, "Write: Mem[ " FMT_PADDR " ] = " FMT_WORD "\tlen = %d", addr, data, len);
    ringBufWrite(&mringbuf, str);
  #endif
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, (paddr_t)CONFIG_MBASE, (paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1, mycpu->pc);
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

// word_t paddr_read(paddr_t addr, int len) {
//   if (likely(in_pmem(addr))) return pmem_read(addr, len);
//   //IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
//   out_of_bound(addr);
//   return 0;
// }

// void paddr_write(paddr_t addr, int len, word_t data) {
//   if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
//   //IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
//   out_of_bound(addr);
// }


extern "C" void inst_fetch(long long  pc, int *inst) {
    if (likely(in_pmem(pc))){
      *inst = host_read(guest_to_host(pc), 4);
    }
    else{
      out_of_bound(pc);
      *inst = 0;
    }
}

#define DEVICE_BASE 0xa0000000
#define SERIAL_PORT     (DEVICE_BASE + 0x00003f8)
#define KBD_ADDR        (DEVICE_BASE + 0x0000060)
#define RTC_ADDR        (DEVICE_BASE + 0x0000048)
#define VGACTL_ADDR     (DEVICE_BASE + 0x0000100)
#define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
#define DISK_ADDR       (DEVICE_BASE + 0x0000300)
#define FB_ADDR         (MMIO_BASE   + 0x1000000)
#define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)
#define CLINT_MSIP_ADDR (0x2000000)
#define CLINT_MTIMECMP_ADDR (0x2004000)
#define CLINT_MTIME_ADDR (0x200BFF8)

static struct timeval boot_time = {};
void timer_init() {
  gettimeofday(&boot_time, NULL);
}

extern "C" void paddr_read(long long raddr, long long *rdata) {
  // 总是读取地址为`raddr & ~0x7ull`的8字节返回给`rdata`
  paddr_t addr = raddr & ~0x7ull;
  if (likely(in_pmem(addr))) {
    *rdata = pmem_read(addr, 8);
  }
  else if(addr == RTC_ADDR){
    struct timeval now;
    gettimeofday(&now, NULL);
    long int seconds = now.tv_sec - boot_time.tv_sec;
    long int useconds = now.tv_usec - boot_time.tv_usec;
    *rdata = seconds * 1000000 + (useconds + 500);
    #if CONFIG_DRINGBUF_DEPTH
      char str[128];
      sprintf(str, "Device R: %10s[%d] = %016llX \tlen = %d", "Timer", 0, *rdata, 8);
      ringBufWrite(&dringbuf, str);
    #endif
    #ifdef CONFIG_DIFFTEST
      difftest_skip_ref();
    #endif
  }
  else if(addr == CLINT_MSIP_ADDR || addr == CLINT_MTIME_ADDR || addr == CLINT_MTIMECMP_ADDR)
  {
    #ifdef CONFIG_DIFFTEST
      difftest_skip_ref();
    #endif
  }
  else out_of_bound(addr);
}

extern "C" void paddr_write(long long waddr, long long wdata, char wmask) {
  // 总是往地址为`waddr & ~0x7ull`的8字节按写掩码`wmask`写入`wdata`
  // `wmask`中每比特表示`wdata`中1个字节的掩码,
  // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
  paddr_t addr = waddr & ~0x7ull;
  if (likely(in_pmem(addr))) { 
    size_t i;
    for (i = 0; i < 8; i++)
    {
      if ((wmask & 1) == 0)
      {
        wmask = (unsigned char)wmask >> 1;
      }
      else break;
    }
    switch ((unsigned char)wmask)
    {
      case 1: pmem_write(addr + i, 1, wdata); break;
      case 3: pmem_write(addr + i, 2, wdata); break;
      case 15: pmem_write(addr + i, 4, wdata); break;
      case 255: pmem_write(addr + i, 8, wdata); break;
      default: break;
    }
  }
  else if(addr == SERIAL_PORT){// && wmask == 1
    {
      putchar(wdata);
      #if CONFIG_DRINGBUF_DEPTH
        char str[128];
        sprintf(str, "Device W: %10s[%d] = %016llX \tlen = %d", "Serial", 0, wdata, 1);
        ringBufWrite(&dringbuf, str);
      #endif
      #ifdef CONFIG_DIFFTEST
        difftest_skip_ref();
      #endif
    }
  }
  else if(addr == CLINT_MSIP_ADDR || addr == CLINT_MTIME_ADDR || addr == CLINT_MTIMECMP_ADDR)
  {
    #ifdef CONFIG_DIFFTEST
      difftest_skip_ref();
    #endif
  }
  else out_of_bound(addr);
}