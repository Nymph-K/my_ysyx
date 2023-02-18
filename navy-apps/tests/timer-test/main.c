#include <stdio.h>
#include <assert.h>
#include <stdint.h>

int main() {
  uint32_t systick;
  uint32_t old_systick;

  printf("Timer-test\n");
  systick = NDL_GetTicks();
  old_systick = systick;

  for (size_t i = 0; i < 10; i++)
  {
    while ((systick - old_systick) < 500)
    {
      systick = NDL_GetTicks();
    }
    old_systick = systick;
    printf("0.5 * %d (s)\n", i);
  }
  return 0;
}
