#include <klibtest.h>

#define N 32

static uint8_t data1[N];
static uint8_t data2[N];

static void reset() {
  int i;
  for (i = 0; i < N; i ++) {
    data1[i] = i + 1;
    data2[i] = i + 1;
  }
}

void test_memcmp(void) {
  int l, r;
  for (l = 0; l < N; l ++) {
    for (r = l + 1; r <= N; r ++) {
      reset();
      uint8_t val = (l + r) / 2;
      memset(data1 + l, val, r - l);
      memset(data2 + l, val, r - l);
      assert(memcmp(data1, data2, N) == 0);
    }
  }
}