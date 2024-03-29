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

#include <common.h>

#pragma GCC diagnostic ignored "-Wunused-function"

#define NR_WP 32
#define WP_TP uint64_t
#define EXP_SIZE 128

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  char *exp;
  WP_TP lastResult;

} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;
static char exp_arry[NR_WP][EXP_SIZE] = {};

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
    wp_pool[i].exp = exp_arry[i];
    wp_pool[i].lastResult = -1;
  }

  head = NULL;
  free_ = wp_pool;
}

static void backPush(WP *head, WP *tail, WP *newNode)
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

static void frontPush(WP **head_ptr, WP *newNode)
{
  newNode->next = *head_ptr;
  *head_ptr = newNode;
} 

static WP* frontPop(WP **head_ptr)
{
  if (*head_ptr == NULL)
  {
    printf("empty list!\n");
    return NULL;
  }
  else
  {
    WP* tmp = *head_ptr;
    *head_ptr = (*head_ptr)->next;
    return tmp;
  }
}

word_t expr(char *e, bool *success);
static WP_TP get_CurrentResult(WP *tmp)
{
  for (WP* cur = head; cur ; cur = cur->next)
  {
    if (tmp == cur){
      bool success;
      cur->lastResult = expr(cur->exp, &success);
      if(success) return cur->lastResult;
      printf("Expression evaluation faild!\n");
      return -1;
    }
  }
  printf("Index error!\n");
  return -1;
}

static WP_TP get_CurrentResultNo(int no)
{
  return get_CurrentResult(wp_pool + no);
}

static WP_TP get_LastResult(WP *tmp)
{
  for (WP* cur = head; cur ; cur = cur->next)
  {
    if (tmp == cur){
      return cur->lastResult;
    }
  }
  printf("Index error!\n");
  return -1;
}

static WP_TP get_LastResultNo(int no)
{
  return get_LastResult(wp_pool + no);
}


int new_wp(char * expression)
{
  if(expression == NULL) return -1;
  if(strlen(expression) >= EXP_SIZE)
  {
    printf("Expression too long!\n");
    return -1;
  }
  if (free_ != NULL)
  {
    WP * tmp = frontPop(&free_);
    if (tmp == NULL) return-1;
    strncpy(tmp->exp, expression, EXP_SIZE);
    tmp->next = NULL;
    frontPush(&head, tmp);
    get_CurrentResult(tmp);
    printf("wp%d : %s \t current = %lu\n", tmp->NO, tmp->exp, tmp->lastResult);
    return tmp->NO;
  }
  else
  {
    printf("out of memory!\n");
    return -1;
  }
}

bool free_wp(WP *wp)
{
  if (head == NULL)
  {
    printf("empty list!\n");
    return false;
  }
  if (wp == head)
  {
    frontPush(&free_, frontPop(&head));
    return true;
  }
  WP *cur = head->next, *pre = head;
  while(cur)
  {
    if (cur == wp){
      pre->next = cur->next;
      frontPush(&free_, cur);
      return true;
    }
    else {
      cur = cur->next;
      pre = pre->next;
    }
  }
  printf("No such WP!\n");
  return false;
}

bool free_no(int no)
{
  if (0 <= no && no <= NR_WP)
    return free_wp(wp_pool + no);
  printf("Index error!\n");
  return false;
}

void info_wp(void)
{
  WP *cur = head;
  while (cur)
  {
    uint64_t lastResult = cur->lastResult;
    uint64_t currentResult = get_CurrentResult(cur);
    printf("wp%d : %s last = %lu \t current = %lu\n", cur->NO, cur->exp, lastResult, currentResult);
    cur = cur->next;
  }
}

bool scan_wp(void)
{
  WP *cur = head;
  bool change = false;
  while (cur)
  {
    uint64_t lastResult = cur->lastResult;
    uint64_t currentResult = get_CurrentResult(cur);
    if(currentResult != lastResult){
      printf("wp%d : %s last = %lu \t current = %lu\n", cur->NO, cur->exp, lastResult, currentResult);
      change = true || change;}
    cur = cur->next;
  }
  return change;
}