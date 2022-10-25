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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>

// this should be enough
static char buf[65536] = {};
static uint16_t ptr = 0;
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static void gen(char c) {
  buf[ptr] = c;
  ptr += 1;
  if (rand() % 2 == 1) {
    buf[ptr] = ' ';
    ptr += 1;
  }// random space
}

static void gen_rand_op() {
  int choose4 = rand() % 4;//%4
  switch (choose4) {
    case 0: gen('+'); break;
    case 1: gen('-'); break;
    case 2: gen('*'); break;
    case 3: gen('/'); break;
    default: printf("ERROE: gen_rand_op! \n"); break;
  }
}

static void gen_num() {
  uint32_t randnum = rand() & (uint8_t)(-1);// % uint32
  sprintf(buf + ptr, "%u", randnum);
  ptr += strlen(buf + ptr);
  if (rand() & 1) {
    buf[ptr] = ' ';
    ptr += 1;
  }// random space
}

/*
 *将表达式展开成高度为depth+1的完全二叉树，将有 2 ** depth 个叶子结点。
 *每个叶子结点代表 数值 或 （数值）。
 *因此，depth深度的表达式，最长为：
 * 2 ** depth * len("( 10位%d数字uint32 ) op")
 *=2 ** depth * 16
 *因此，最大深度 MAX（depth）= log2(65536 / 16) = 12
 */
static void gen_rand_expr(bool noMoreBrackets, uint8_t depth) {
  int choose3;
  if (noMoreBrackets)// Avoid multiple Brackets (( ... ))
  {
    if (depth == 12)// Avoid buf overflow
    {
      choose3 = 0;
    }
    else
    {
      choose3 = rand() % 2;//0, 1
    }
  }
  else
  {
    if (depth == 12)// Avoid buf overflow
    {
      choose3 = rand() % 2 == 0 ? 0 : 2;//0, 2
    }
    else
    {
      choose3 = rand() % 3;// 0, 1, 2
    }
  }
  
  switch (choose3) {
    case 0: gen_num(); break;
    case 1: gen_rand_expr(false, depth + 1); gen_rand_op(); gen_rand_expr(false, depth + 1); break;
    default: gen('('); gen_rand_expr(true, depth); gen(')'); break;
  }
}

//extern uint64_t expr(char *e, bool *success);
extern int errno ;

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  bool success;
  uint32_t result = 0, last_result = 0;
  int errnum;
  for (i = 0; i < loop; i ++) {
    do{
      ptr = 0; gen_rand_expr(false, 0); buf[ptr] = '\0';//generate expression
      //result = expr(buf, &success);
      
      sprintf(code_buf, code_format, buf);//generate c source file
      FILE *fp = fopen("/tmp/.code.c", "w");
      assert(fp != NULL);
      fputs(code_buf, fp);
      fclose(fp);

      int ret = system("gcc -Wno-overflow /tmp/.code.c -o /tmp/.expr");//-Wno-div-by-zero  -Wno-overflow
      errnum = errno;
      if (errnum != 0 && ret != 0) {
        printf("ret= %d ERR_NUM: %d ( %s )\n", ret, errnum, strerror( errnum ));
        continue;
      }

      fp = popen("/tmp/.expr", "r");
      assert(fp != NULL);

      last_result = result;
      fscanf(fp, "%u", &result);
      pclose(fp);

      if(result != last_result) printf("%u %s\n", result, buf);
    }while(result == last_result);// maybe divided by 0, maybe!!! re=^(\d+) .*\n\1 
  }
  return 0;
}
