#include <klibtest.h>

#define N 32

static uint8_t data[N];

static void reset() {
  int i;
  for (i = 0; i < N; i ++) {
    data[i] = i + 1;
  }
}

static void check_seq(int dst, int src, int n) {
  int i;
  for (i = 0; i < n; i ++) {
    assert(data[dst+i] == src + i + 1);
  }
}

void test_memmove(void) {
  int l, r;
  for (l = 0; l < N; l ++) {
    for (r = l; r < N; r ++) {
      for (size_t n = 0; n <= N - r; n++)
      {
        reset();
        memmove(data + l, data + r, n);
        check_seq(l, r, n);

        reset();
        memmove(data + r, data + l, n);
        check_seq(r, l, n);
      }
    }
  }
}