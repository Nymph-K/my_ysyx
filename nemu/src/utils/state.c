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
#include <stdio.h>
#include <isa.h>
#include <memory/paddr.h>

NEMUState nemu_state = { .state = NEMU_STOP };


int is_exit_status_bad() {
  int good = (nemu_state.state == NEMU_END && nemu_state.halt_ret == 0) ||
    (nemu_state.state == NEMU_QUIT);
  return !good;
}

bool save_status(const char *abs_path)
{
  const char *file_path = abs_path ? abs_path : "/home/k/ysyx-workbench/nemu/nemu-status.bkp";
  FILE *fp = fopen(file_path, "w");
  if(!fp){
    printf("Creat Snapshot failed: File open failed!\n");
    return false;
  }
  if(fwrite(&cpu, sizeof(CPU_state), 1, fp) != 1)
  {
    fclose(fp);
    printf("Creat Snapshot failed: Save cpu status failed!\n");
    return false;
  }
  if(fwrite(guest_to_host(RESET_VECTOR), CONFIG_MSIZE, 1, fp) != 1)
  {
    fclose(fp);
    printf("Creat Snapshot failed: Save memory failed!\n");
    return false;
  }
  fclose(fp);
  printf("Creat Snapshot success!\n");
  return true;
}

void difftest_copy_to_ref(void);
bool load_status(const char *abs_path)
{
  const char *file_path = abs_path ? abs_path : "/home/k/ysyx-workbench/nemu/nemu-status.bkp";
  FILE *fp = fopen(file_path, "r");
  if(!fp){
    printf("Load Snapshot failed: File open failed!\n");
    return false;
  }
  if(fread(&cpu, sizeof(CPU_state), 1, fp) != 1)
  {
    fclose(fp);
    nemu_state.state = NEMU_ABORT;
    printf("Load Snapshot failed: Load cpu status failed!\n");
    return false;
  }
  if(fread(guest_to_host(RESET_VECTOR), CONFIG_MSIZE, 1, fp) != 1)
  {
    fclose(fp);
    nemu_state.state = NEMU_ABORT;
    printf("Load Snapshot failed: Load memory failed!\n");
    return false;
  }
  fclose(fp);
  nemu_state.state = NEMU_STOP;
  #ifdef CONFIG_DIFFTEST
    difftest_copy_to_ref();
  #endif
  printf("Load Snapshot success!\n");
  return true;
}