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

#define TEST_EXPRESSION 1


#if TEST_EXPRESSION

word_t expr(char *e, bool *success);
void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();

void test_expression(void);

int main(int argc, char *argv[]) {
    /* Initialize the monitor. */
  #ifdef CONFIG_TARGET_AM
    am_init_monitor();
  #else
    init_monitor(argc, argv);
  #endif

  /* Start engine. */
  engine_start();

  test_expression();

  return is_exit_status_bad();

}

void test_expression(void)
{
  uint32_t resultin, resultout;
  char buf[1024];
  bool success;
  int a, b , i=0;
  FILE *fin = fopen("/home/k/ysyx-workbench/nemu/tools/gen-expr/inputfile", "r");
  FILE *fout = fopen("/home/k/ysyx-workbench/nemu/tools/gen-expr/outputfile", "w");
  if (fin == NULL || fout == NULL)
  {
    printf("NULL!\n");
    return ;
  }
  while (!feof(fin))
  //for (uint8_t i = 0; i < 100; i++)
  {
    //printf("Expression: %d ", i);
    a = fscanf(fin, "%u ", &resultin);
    fgets(buf, 1024, fin);
    if(!feof(fin)) buf[strlen(buf)-1] = '\0';
    else buf[strlen(buf)] = '\0';
    //printf("a = %d, resultin = %u, buf = %s\n", a, resultin, buf);
    resultout = expr(buf, &success);
    //printf("resultout = %u, success = %d\n", resultout, success);
    if(resultin != resultout || !success){
      fprintf(fout, "in = 0x%x, out = 0x%x, %s\n", resultin, resultout, buf);
      printf("len = %u, str = %s\n", strlen(buf), buf);
    }
    else{
      fprintf(fout, "success! \n");
      //printf("success! in = %u, out = %u\n", resultin, resultout);
    }
    i++;
  }
  fclose(fin);
  fclose(fout);
}

#else /*TEST_EXPRESSION*/

void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();

int main(int argc, char *argv[]) {
  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

  /* Start engine. */
  engine_start();

  return is_exit_status_bad();
}

#endif /*TEST_EXPRESSION*/