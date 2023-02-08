#include <klibtest.h>

#define N 32

static uint8_t data1[N];
static uint8_t data2[N];

static void reset(int val) {
  int i;
  for (i = 0; i < N; i ++) {
    data1[i] = val;
    data2[i] = i + 1;
  }
}


static void check_eq(int dst, int val, int n) {
  int i;
  for (i = 0; i < dst; i ++) {
    assert(data1[i] == val);
  }
  for (i = dst + n; i < N; i ++) {
    assert(data1[i] == val);
  }
}


static void check_seq(int dst, int src, int n) {
  int i;
  for (i = 0; i < n; i ++) {
    assert(data1[dst+i] == data2[src+i]);
  }
}

void test_memcpy(void) {
  int l, r;
  for (l = 0; l < N; l ++) {
    for (r = l; r < N; r ++) {
      uint8_t val = (l + r) / 2;
      for (size_t n = 0; n < N-r; n++)
      {
        reset(val);
        memcpy(data1 + l, data2 + r, n);
        check_eq(l, val, n);
        check_seq(l, r, n);

        reset(val);
        memcpy(data1 + r, data2 + l, n);
        check_eq(r, val, n);
        check_seq(r, l, n);
      }
    }
  }
}