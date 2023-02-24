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
#include <elf_pars.h>

#pragma GCC diagnostic ignored "-Wunused-function"

#define NR_BP 32
#define FUNC_NAME_LEN 128

typedef struct breakpoint {
  int NO;
  struct breakpoint *next;

  char *func_name;
  //bool func_catch;
  int idx_of_sym;
  int idx_of_elf;

} BP;

static BP bp_pool[NR_BP] = {};
static BP *head = NULL, *free_ = NULL;
static char func_name_arry[NR_BP][FUNC_NAME_LEN] = {};

void init_bp_pool() {
  int i;
  for (i = 0; i < NR_BP; i ++) {
    bp_pool[i].NO = i;
    bp_pool[i].next = (i == NR_BP - 1 ? NULL : &bp_pool[i + 1]);
    bp_pool[i].func_name = func_name_arry[i];
    //bp_pool[i].func_catch = false;
    bp_pool[i].idx_of_elf = -1;
    bp_pool[i].idx_of_sym = -1;
  }

  head = NULL;
  free_ = bp_pool;
}

static void backPush(BP *head, BP *tail, BP *newNode)
{
  if(head == NULL)
  {
    head = newNode;
    tail = newNode;
  }
  else
  {
    tail->next = newNode;
    tail = newNode;
  }
}

static void frontPush(BP **head_ptr, BP *newNode)
{
  newNode->next = *head_ptr;
  *head_ptr = newNode;
} 

static BP* frontPop(BP **head_ptr)
{
  if (*head_ptr == NULL)
  {
    printf("empty list!\n");
    return NULL;
  }
  else
  {
    BP* tmp = *head_ptr;
    *head_ptr = (*head_ptr)->next;
    return tmp;
  }
}

bool new_bp(char * fname)
{
  if(fname == NULL) return false;
  if(strlen(fname) >= FUNC_NAME_LEN)
  {
    printf("Function name too long!\n");
    return false;
  }

  int idxOfSym, idxOfElf;
  if(is_func_name(fname, &idxOfSym, &idxOfElf))
  {
    if (free_ != NULL)
    {
      BP *tmp = frontPop(&free_);
      if (tmp == NULL) return false;
      strncpy(tmp->func_name, fname, FUNC_NAME_LEN);
      tmp->idx_of_sym = idxOfSym;
      tmp->idx_of_elf = idxOfElf;
      tmp->next = NULL;
      frontPush(&head, tmp);
      printf("bp %d: %s added!\n", tmp->NO, tmp->func_name);
      return true;
    }
    else
    {
      printf("out of memory!\n");
      return false;
    }
  }
  else
  {
    printf("Function symbol not found!\n");
    return false;
  }
}

bool free_bp(BP *bp)
{
  if (head == NULL)
  {
    printf("empty list!\n");
    return false;
  }
  if (bp == head)
  {
    frontPush(&free_, frontPop(&head));
    return true;
  }
  BP *cur = head->next, *pre = head;
  while(cur)
  {
    if (cur == bp){
      pre->next = cur->next;
      frontPush(&free_, cur);
      return true;
    }
    else {
      cur = cur->next;
      pre = pre->next;
    }
  }
  printf("No such BP!\n");
  return false;
}

bool free_bp_no(int no)
{
  if (0 <= no && no <= NR_BP)
    return free_bp(bp_pool + no);
  printf("Index error!\n");
  return false;
}

void info_bp(void)
{
  BP *cur = head;
  while (cur)
  {
    //printf("bp %d: %s catch = %s\n", cur->NO, cur->func_name, cur->func_catch ? "true!" : "false");
    printf("bp %d: %s\n", cur->NO, cur->func_name);
    cur = cur->next;
  }
}

bool scan_bp(char *fname)
{
  if(fname == NULL) return false;
  BP *cur = head;
  while (cur)
  {
    if(strncmp(fname, cur->func_name, FUNC_NAME_LEN) == 0)
    {
      //cur->func_catch = true;
      printf("bp %d: %s catch!\n", cur->NO, cur->func_name);
      return true;
    }
    cur = cur->next;
  }
  return false;
}