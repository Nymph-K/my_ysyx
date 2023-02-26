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

#include <common.h>
#include <memory/paddr.h>

NPCState npc_state = { .state = NPC_STOP };

void exit_cpu(void);

int is_exit_status_bad() {
  int good = (npc_state.state == NPC_END && npc_state.halt_ret == 0) ||
    (npc_state.state == NPC_QUIT);
  exit_cpu();
  return !good;
}

bool save_status(const char *abs_path)
{
  const char *file_path = abs_path ? abs_path : "/home/k/ysyx-workbench/npc/npc-status.bkp";
  FILE *fp = fopen(file_path, "w");
  if(!fp){
    printf("Creat Snapshot failed: File open failed!\n");
    return false;
  }
  if(fwrite(mycpu, sizeof(TOP_NAME), 1, fp) != 1)
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
  const char *file_path = abs_path ? abs_path : "/home/k/ysyx-workbench/npc/npc-status.bkp";
  FILE *fp = fopen(file_path, "r");
  if(!fp){
    printf("Load Snapshot failed: File open failed!\n");
    return false;
  }
  if(fread(mycpu, sizeof(TOP_NAME), 1, fp) != 1)//private can not write
  {
    fclose(fp);
    npc_state.state = NPC_ABORT;
    printf("Load Snapshot failed: Load cpu status failed!\n");
    return false;
  }
  if(fread(guest_to_host(RESET_VECTOR), CONFIG_MSIZE, 1, fp) != 1)
  {
    fclose(fp);
    npc_state.state = NPC_ABORT;
    printf("Load Snapshot failed: Load memory failed!\n");
    return false;
  }
  fclose(fp);
  npc_state.state = NPC_STOP;
  #ifdef CONFIG_DIFFTEST
    difftest_copy_to_ref();
  #endif
  printf("Load Snapshot success!\n");
  return true;
}
