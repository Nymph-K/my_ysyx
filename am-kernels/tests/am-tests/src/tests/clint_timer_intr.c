#include <amtest.h>

#if HAS_CLINT_INTR
static uint64_t timecmp = 0x1;

Context *clint_timer_trap(Event ev, Context *ctx) {
  switch(ev.event) {
    case EVENT_IRQ_TIMER:
      timecmp += 0x1;
      io_write(AM_CLINT_MTIMECMP, timecmp, true);//clean mtip
      printf("Event Timer irq: ");
      break;
    case EVENT_YIELD:
      printf("Event yield: ");
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
  while (1) {
    for (volatile int i = 0; i < 100000; i++) ;
    yield();
  }
}
#endif