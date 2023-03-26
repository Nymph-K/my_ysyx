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
#include <memory/host.h>
#include <memory/vaddr.h>
#include <device/map.h>
#include <cpu/ringbuf.h>

#define IO_SPACE_MAX (2 * 1024 * 1024)

static uint8_t *io_space = NULL;
static uint8_t *p_space = NULL;

uint8_t* new_space(int size) {
  uint8_t *p = p_space;
  // page aligned;
  size = (size + (PAGE_SIZE - 1)) & ~PAGE_MASK;// 4KB align 1_0000_0000_0000
  p_space += size;
  assert(p_space - io_space < IO_SPACE_MAX);
  return p;
}

#if OUT_BOUND_CONTINUE
static int check_bound(IOMap *map, paddr_t addr) {
  if (map == NULL) {
    printf(ANSI_FMT("address (" FMT_PADDR ") is out of bound at pc = " FMT_WORD "\n", ANSI_FG_RED), addr, mycpu->pc);
    return 1;
  } else {
    if(addr <= map->high && addr >= map->low) return 0;
    else{
      printf(ANSI_FMT("address (" FMT_PADDR ") is out of bound {%s} [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD "\n", ANSI_FG_RED),
        addr, map->name, map->low, map->high, mycpu->pc);
        return 1;
      }
  }
}
#else
static void check_bound(IOMap *map, paddr_t addr) {
  if (map == NULL) {
    Assert(map != NULL, "address (" FMT_PADDR ") is out of bound at pc = " FMT_WORD, addr, mycpu->pc);
  } else {
    Assert(addr <= map->high && addr >= map->low,
        "address (" FMT_PADDR ") is out of bound {%s} [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
        addr, map->name, map->low, map->high, mycpu->pc);
  }
}
#endif

static void invoke_callback(io_callback_t c, paddr_t offset, int len, bool is_write) {
  if (c != NULL) { c(offset, len, is_write); }
}

void init_map() {
  io_space = (uint8_t *)malloc(IO_SPACE_MAX);
  assert(io_space);
  p_space = io_space;
}

word_t map_read(paddr_t addr, int len, IOMap *map) {
  assert(len >= 1 && len <= 8);
#if OUT_BOUND_CONTINUE
  if (check_bound(map, addr))
  {
    void set_npc_state(int state, vaddr_t pc, int halt_ret);
    set_npc_state(NPC_ABORT, mycpu->pc, -1);
    extern void isa_reg_display();
    isa_reg_display();
    return 0;
  }
#else
  check_bound(map, addr);
#endif
  paddr_t offset = addr - map->low;
  invoke_callback(map->callback, offset, len, false); // prepare data to read
  word_t ret = host_read((uint8_t *)(map->space) + offset, len);
  #if CONFIG_DRINGBUF_DEPTH
    if(enable_ringbuf){
      char str[128];
      sprintf(str, "Device R: %10s[%d] = " FMT_WORD " \tlen = %d", map->name, offset, ret, len);
      ringBufWrite(&dringbuf, str);
    }
  #endif
  return ret;
}

void map_write(paddr_t addr, int len, word_t data, IOMap *map) {
  assert(len >= 1 && len <= 8);
  check_bound(map, addr);
  paddr_t offset = addr - map->low;
  host_write((uint8_t *)(map->space) + offset, len, data);
  invoke_callback(map->callback, offset, len, true);
  #if CONFIG_DRINGBUF_DEPTH
    if(enable_ringbuf){
      char str[128];
      sprintf(str, "Device W: %10s[%d] = " FMT_WORD " \tlen = %d", map->name, offset, data, len);
      ringBufWrite(&dringbuf, str);
    }
  #endif
}
