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

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ, TK_NUM

  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"==", TK_EQ},        // equal
  {"[0-9]+", TK_NUM},      // decimal number, float
  {"\\+", '+'},         // plus
  {"-", '-'},           // subtract
  {"\\*", '*'},         // multiply
  {"/", '/'},           // ivide
  {"\\(", '('},         // left bracket
  {"\\)", ')'},         // right bracket
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

#define MAX_STR_LEN 32
typedef struct token {
  int type;
  char str[MAX_STR_LEN];
} Token;

#define MAX_TOKEN_NUM 512
static Token tokens[MAX_TOKEN_NUM] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0' && nr_token < MAX_TOKEN_NUM) {//nr_token >= MAX_TOKEN_NUM , buffer overflow
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        //Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
        //    i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
          case '+': case '-': case '*': case '/': case '(': case ')': case TK_EQ:
            tokens[nr_token].type = rules[i].token_type;
            nr_token ++;
            break;
          case TK_NUM:
            if(substr_len < MAX_STR_LEN) {
              tokens[nr_token].type = rules[i].token_type;
              strncpy(tokens[nr_token].str, substr_start, substr_len);
              tokens[nr_token].str[substr_len] = '\0';
              nr_token ++;
            }else{//length >= MAX_STR_LEN, str => uint32 => str
              uint32_t num;
              tokens[nr_token].type = rules[i].token_type;
              sscanf(substr_start, "%u%*s", &num);
              sprintf(tokens[nr_token].str, "%u", num);
              printf("Number too long!\n");
              return false;
            }

          default: /*TODO()*/;//space not save
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }
  if (e[position] != '\0' && nr_token >= MAX_TOKEN_NUM)//nr_token >= MAX_TOKEN_NUM , buffer overflow
  {
    printf("Expression too long!\n");
    return false;
  }
  

  return true;
}



bool check_parentheses(uint16_t p, uint16_t q) {
  if(tokens[p].type == '(' && tokens[q].type == ')')
  {
    int16_t cnt = 1;
    uint16_t i;
    for (i = p + 1; cnt > 0 && i < q; i++)
    {
        if (tokens[i].type == '(') cnt += 1;
        else if (tokens[i].type == ')') cnt -= 1;
    }
    if(cnt == 1 && i == q) return true;
    else return false;
  }
  else 
    return false;
}

#define UNSIGNED_CALCU 0//1: 在计算过程中就使用的无符号. 0: 在计算过程中使用有符号计算仅将最终结果转换为无符号
#define SHORT_CIRCUIT_OPERATOR 1

uint32_t eval(uint16_t p, uint16_t q, bool *success) {
  if (p > q) {
    /* Bad expression */
    printf("Bad expression! %s %d\n", __FILE__, __LINE__);
    *success = false;
    return -1;
  }
  else if (p == q) {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
    uint32_t num;
    sscanf(tokens[p].str, "%u", &num);
    *success = true;
    return num;
  }
  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    //printf("check_parentheses = true");
    return eval(p + 1, q - 1, success);
  }
  else {
    uint16_t op = p;
    for (uint16_t i = p; i <= q; i++)//positioning op
    {
      switch (tokens[i].type)
      {
      case '+':
        op = i;
        break;

      case '-': //minus = num - expression || (...) - expression; negative = others
        if(tokens[i-1].type == TK_NUM || tokens[i-1].type == ')')
          op = i;
        break;
      
      case '*': case '/': 
        if(tokens[op].type != '+' && tokens[op].type != '-') op = i;
        break;

      case '(':
        int16_t cnt;
        i++;
        for (cnt = 1; cnt > 0 && i <= q; i++)//match right bracket ')'
        {
          if (tokens[i].type == '(') cnt += 1;
          else if(tokens[i].type == ')') cnt -= 1;
        }
        i--;
        if (cnt != 0 && i <= q)//brackets mismatch
        {
          *success = false;
          printf("Illegal expression! file: %s line: %d p=%d,i=%d,q=%d,cnt=%d\n", __FILE__, __LINE__, p, i, q, cnt);
          printf("tokens[i].type=%c\n", tokens[i].type);
          return -1;
        }
        //printf(",i=%d ",i);
        break;

      case ')'://brackets mismatch
        *success = false;
        printf("Brackets mismatch! file: %s line: %d p=%d,i=%d,q=%d\n", __FILE__, __LINE__, p, i, q);
        return -1;
        break;

      default:
        break;
      }
    }

    //printf("p=%d,op=%d,q=%d\n", p, op, q);
    uint32_t val1 = 0, val2 = 0;
    if (op == p && tokens[op].type == '-')// negative expression
    {
      val1 = 0;
    }
    else
    {
      val1 = eval(p, op - 1, success);
      if (*success == false) return -1;
    }
#if SHORT_CIRCUIT_OPERATOR 
    if(tokens[op].type == '*' && val1 == 0)
    {
      val2 = 0;
    }
    else
    {
      val2 = eval(op + 1, q, success);
      if (*success == false) return -1;
    }
#else
    val2 = eval(op + 1, q, success);
    if (*success == false) return -1;
#endif

    switch (tokens[op].type) {
      case '+': 
        *success = true;
        return MUXONE(UNSIGNED_CALCU, val1 + val2, (signed)val1 + (signed)val2);
        break;
      case '-': 
        *success = true;
        return MUXONE(UNSIGNED_CALCU, val1 - val2, (signed)val1 - (signed)val2);
        break;
      case '*': 
        *success = true;
        return MUXONE(UNSIGNED_CALCU, val1 * val2, (signed)val1 * (signed)val2);
        break;
      case '/': 
        if( val2 == 0 )
        {
          *success = false;
          printf("Divided by zero! %s %d\n", __FILE__, __LINE__);
          return -2;
        }
        *success = true;
        return MUXONE(UNSIGNED_CALCU, val1 / val2, (signed)val1 / (signed)val2);
        break;
      default: 
        *success = false;
        assert(0);
    }
  }
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }
  return eval(0, nr_token - 1, success);
}