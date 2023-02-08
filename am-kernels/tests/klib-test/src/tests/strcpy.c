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

// 检查[l, l + N - r)区间中的值是否依次为tbl[r], tbl[r+1], tbl[r+2]...
static void check_seq(int l, int r) {
  int i;
  for (i = 0; i < N - r; i ++) {
    assert(str[l + i] == tbl[r + i]);
  }
}

// 检查[l,r)区间中的值是否均为val
static void check_eq(int l, int r, char c) {
  int i;
  for (i = l; i < r; i ++) {
    assert(str[i] == c);
  }
}
//str : -----l-------------------
//tbl : -----------r-------------
void test_strcpy(void) {
  int l, r;
  for (l = 0; l < N; l ++) {
    for (r = l; r < N; r ++) {
        size_t u = (l + r) / 2;
        reset(tbl[u]);
        strcpy(str + l, tbl + r);

        check_eq(0, l, tbl[u]);
        check_seq(l, r);
        check_eq(l + N - r, N, tbl[u]);
    }
  }
}