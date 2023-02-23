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

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"
#include <memory/paddr.h>

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();
void init_bp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}


static int cmd_q(char *args) {
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args) {
  if (args == NULL) { 
    cpu_exec(1);
    return 0;
  }else{
    uint32_t step_num;
    char *arg;
    arg = strtok(args, " ");
    if(strtok(NULL, " ") == NULL){
      sscanf(arg, "%u", &step_num);
      cpu_exec(step_num);
      return 0;
    }else{
      printf("Too many arguments!\n");
      return 1;
    }
  }
}

void info_wp(void);
void info_bp(void);
static int cmd_info(char *args) {
  if (args == NULL) { 
      printf("Too few arguments!\n");
      return 1;
  }else{
    char arg;
    sscanf(args, "%c", &arg);
    switch (arg)
    {
      case 'r':
        isa_reg_display();
        return 0;
        break;
      case 'w':
        info_wp();
        return 0;
        break;
      case 'b':
        info_bp();
        return 0;
        break;
      
      default:
        printf("Argument illegal!\n");
        return 1;
        break;
    }
  }
}

static int cmd_x(char *args) {
  if (args == NULL) { 
    printf("Too few arguments!\n");
    return 1;
  }else{
    uint32_t num;
    uint32_t addr;
    char *arg;
    arg = strtok(args, " ");
    sscanf(arg, "%u", &num);
    arg = strtok(NULL, " ");
    if(arg == NULL){
      printf("Too few arguments!\n");
      return 1;
    }else{
      sscanf(arg, "%x", &addr);
      for (uint32_t i = 0; i < num; i++)
      {
        printf("[0x%08x] = 0x%08lx\n", addr + i*4, paddr_read(addr + i*4, 4));
      }
      return 0;
    }
  }
}

static int cmd_p(char *args) {
  if (args == NULL) { 
    printf("Too few arguments!\n");
    return 1;
  }else{
    uint64_t result;
    bool success;
    result = expr(args, &success);
    if(success){
      printf(" = 0x%-8lx = %lu\n", result, result);
      return 0;
    }
    else{
      printf("Expression evaluation failed!\n");
      return 1;
    }
  }
}

int new_wp(char * expression);
static int cmd_w(char *args) {
  if (args == NULL) { 
    printf("Too few arguments!\n");
    return 1;
  }else{
    int no = new_wp(args);
    if(no != -1){
      //uint64_t result = get_LastResultNo(no);
      printf("Set watch point success!\n");
      return 0;
    }
    else{
      printf("Set watch point failed!\n");
      return 1;
    }
  }
}

bool free_no(int no);
static int cmd_d(char *args) {
  if (args == NULL) { 
    printf("Too few arguments!\n");
    return 1;
  }else{
    int num;
    char *arg;
    arg = strtok(args, " ");
    sscanf(arg, "%d", &num);
    if (free_no(num)){
      printf("wp%d deleted success!\n", num);
      return 0;}
    else{
      printf("wp%d deleted faild!\n", num);
      return 1;}
  }
}

bool new_bp(char * fname);
static int cmd_b(char *args) {
  if (args == NULL) { 
    printf("Too few arguments!\n");
    return 1;
  }else{
    bool success = new_bp(args);
    if(success){
      //uint64_t result = get_LastResultNo(no);
      printf("Set break point success!\n");
      return 0;
    }
    else{
      printf("Set break point failed!\n");
      return 1;
    }
  }
}

bool free_bp_no(int no);
static int cmd_db(char *args) {
  if (args == NULL) { 
    printf("Too few arguments!\n");
    return 1;
  }else{
    int num;
    char *arg;
    arg = strtok(args, " ");
    sscanf(arg, "%d", &num);
    if (free_bp_no(num)){
      printf("bp %d deleted success!\n", num);
      return 0;}
    else{
      printf("bp %d deleted faild!\n", num);
      return 1;}
  }
}

#ifdef CONFIG_DIFFTEST
extern bool disable_diff;
static int cmd_detach(char *args) {
  disable_diff = true;
  printf("\033[0m\033[1;31mExit \033[0mDiffTest  mode!\n");
  return 0;
}

void difftest_attach(void);
static int cmd_attach(char *args) {
  disable_diff = false;
  difftest_attach();
  printf("\033[0m\033[1;32mEnter \033[0mDiffTest mode!\n");
  return 0;
}
#endif

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display informations about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "Single step execute the program.\t arg: N. Example: (nemu) si 10", cmd_si },
  { "info", "Print program status.\t arg: r|w|b. Example: (nemu) info r", cmd_info },
  { "x", "Scan memory.\t arg: N EXPR. Example: (nemu) x 10 $esp", cmd_x },
  { "p", "Expression evaluation.\t arg: EXPR. Example: (nemu) p $esp", cmd_p },
  { "w", "Set watch point.\t arg: EXPR. Example: (nemu) w $esp", cmd_w },
  { "d", "Delete watch point.\t arg: N. Example: (nemu) d 2", cmd_d },
  { "b", "Set break point by function name.\t arg: name. Example: (nemu) b func_name", cmd_b },
  { "db", "Delete break point by number.\t arg: number. Example: (nemu) db 0", cmd_db },
#ifdef CONFIG_DIFFTEST
  { "detach", "Exit DiffTest mode.\t Example: (nemu) detach", cmd_detach },
  { "attach", "Enter DiffTest mode.\t Example: (nemu) attach", cmd_attach },
#endif

  /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watch point pool. */
  init_wp_pool();
  
  /* Initialize the break point pool. */
  init_bp_pool();
}
