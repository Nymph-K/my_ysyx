#include <klibtest.h>

static char tbl[] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
#define N sizeof(tbl)
static char str1[N];
static char str2[N];

static void reset(char c) {
  int i;
  for (i = 0; i < N; i ++) {
    str1[i] = c;
    str2[i] = c;
  }
}

//str : -----l-------------------
//tbl : -----------r-------------
void test_strcmp(void) {
  int l, r;
  for (l = 0; l < N; l ++) {
    for (r = l; r < N; r ++) {
        size_t u = (l + r) / 2;
        reset(tbl[u]);
        strcpy(str1 + l, tbl + r);
        strcpy(str2 + l, tbl + r);
        assert(strcmp(str1, str2) == 0);
    }
  }
}

void test_strncmp(void) {
  int l, r;
  for (l = 0; l < N; l ++) {
    for (r = l; r < N; r ++) {
        size_t u = (l + r) / 2;
        reset(tbl[u]);
        strcpy(str1 + l, tbl + r);
        strcpy(str2 + l, tbl + r);
        for (size_t n = 0; n <= N; n++)
        {
          assert(strncmp(str1, str2, n) == 0);
        }
        
    }
  }
}