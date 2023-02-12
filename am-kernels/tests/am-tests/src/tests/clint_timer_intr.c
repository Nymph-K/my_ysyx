#include <amtest.h>

#if HAS_CLINT_INTR
static uint64_t timecmp = 0x40;

Context *clint_timer_trap(Event ev, Context *ctx) {
  switch(ev.event) {
    case EVENT_IRQ_TIMER:
      timecmp += 0x80;
      io_write(AM_CLINT_MTIMECMP, timecmp, true);//clean mtip
      printf("t: ");
      break;
    case EVENT_YIELD:
      printf("y: ");
      break;
    default:
      break;
  }
  return ctx;
}

void clint_timer_intr() {
  printf("Hello, AM World @ " __ISA__ "\n");
  printf("  t = timer, d = device, y = yield\n");
  io_read(AM_INPUT_CONFIG);
  io_write(AM_CLINT_MTIME, 0, true);
  io_write(AM_CLINT_MTIMECMP, timecmp, true);
  iset(1);
  for (size_t j = 0; j < 5; j++)
  {
    for (volatile int i = 0; i < 50000; i++) ;
    yield();
  }
  iset(0);
}
#endif