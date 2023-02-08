#include <klibtest.h>


static char tbl[] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
#define N sizeof(tbl)
static char str[N];

static void reset(char c) {
  int i;
  for (i = 0; i < N; i ++) {
    str[i] = c;
  }
}
//str : -----l-------------------
//tbl : -----------r-------------
void test_strlen(void) {
  int l, r;
  for (l = 0; l < N; l ++) {
    for (r = l; r < N; r ++) {
        size_t u = (l + r) / 2;
        reset(tbl[u]);
        strcpy(str + l, tbl + r);

        assert(strlen(str + l) == N - r - 1);
    }
  }
}