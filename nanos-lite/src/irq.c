#include <common.h>

void do_syscall(Context *c);

static Context* do_event(Event e, Context* c) {
  switch (e.event) {
    case EVENT_YIELD: do_syscall(c); break;//printf("Event yield!\n"); 
    case EVENT_SYSCALL: do_syscall(c); break;//printf("System call!\n"); 
    case EVENT_IRQ_TIMER: printf("Machine timer interrupt!\n");break;
    case EVENT_IRQ_IODEV: printf("Machine external interrupt!\n");break;
    case EVENT_IRQ_SOFT: printf("Machine software interrupt!\n");break;
    default: panic("Unhandled event ID = %d", e.event);
  }

  return c;
}

void init_irq(void) {
  Log("Initializing interrupt/exception handler...");
  cte_init(do_event);
}
