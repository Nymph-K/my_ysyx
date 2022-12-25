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
#include <device/mmio.h>
#include <isa.h>
#include <cpu/ringbuf.h>

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
      addr, (paddr_t)CONFIG_MBASE, (paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1, cpu.pc);
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

word_t paddr_read(paddr_t addr, int len) {
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}

u_int8_t mem_data[STACK_DP] = {0,};

u_int8_t mem_access(TOP_NAME* cpu) {
  #define MEM_SUCCESS 0
  #define MEM_ERROR 1
  #define MEM_NOACCESS 2
  u_int64_t offset;
  if (cpu->mem_r)
  {
    offset = cpu->mem_addr - 0x80000000;
    if(offset <= STACK_DP){
      cpu->mem_rdata = *((u_int64_t *)(mem_data+offset));
      debug_printf("load  = 0x%16lX      data = 0x%16lX      mem = 0x%16lX\n", cpu->mem_addr, cpu->mem_rdata, *((u_int64_t *)(mem_data+offset)));
      return MEM_SUCCESS;
    }
    else {
      debug_printf("Memory access out of bounds!\n");
      return MEM_ERROR;
    }
  }
  if (cpu->mem_w)
  {
    offset = cpu->mem_addr - 0x80000000;
    if(offset <= STACK_DP){
      switch (cpu->mem_dlen) {
        case 0: *((u_int8_t *)(mem_data+offset)) = (u_int8_t)cpu->mem_wdata;break;
        case 1: *((u_int16_t *)(mem_data+offset)) = (u_int16_t)cpu->mem_wdata;break;
        case 2: *((u_int32_t *)(mem_data+offset)) = (u_int32_t)cpu->mem_wdata;break;
        case 3: *((u_int64_t *)(mem_data+offset)) = (u_int64_t)cpu->mem_wdata;break;
        default: break; }
      return MEM_SUCCESS;
    }
    else {
      debug_printf("Memory access out of bounds!\n");
      return MEM_ERROR;
    }
  }
  return MEM_NOACCESS;
}


u_int8_t get_inst(TOP_NAME* cpu) {
  u_int64_t offset;
  offset = cpu->pc - 0x80000000;
  if(offset <= STACK_DP){
    cpu->inst = *((u_int32_t *)(mem_data+offset));
    return MEM_SUCCESS;
  }
  else {
    debug_printf("Memory access out of bounds!\n");
    return MEM_ERROR;
  }
}

char base_name[50];//base_name: dummy
char abso_name[100];//Absolute path
int load_bin(char *bin_file){
  FILE *binFile = NULL;
  if(bin_file[0] == '/'){
    //Absolute path: /home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/dummy-riscv64-npc.bin
    strcpy(abso_name, bin_file);
    strcpy(base_name, strrchr(bin_file, '/')+1);
    size_t j = strlen(base_name) - 16;
    base_name[j] = '\0';
  } else {
    // base_name: dummy
    strcpy(base_name, bin_file);
    strcpy(abso_name, "/home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/");
    strcat(abso_name, bin_file);
    strcat(abso_name, "-riscv64-npc.bin");
  }
  binFile = fopen(abso_name, "rb");
  if(binFile != NULL){
    fread(mem_data, 1, STACK_DP, binFile);
    fclose(binFile);
    return 0;
  }else{
    printf("NO such file: %s !\n", abso_name);
    fclose(binFile);
    return 1;
  }
}
