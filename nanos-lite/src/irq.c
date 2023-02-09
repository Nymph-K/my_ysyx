#include <common.h>

static Context* do_event(Event e, Context* c) {
  switch (e.event) {
    case 1: printf("Event yield!\n");break;
    case 5: printf("Machine timer interrupt!\n");break;
    case 6: printf("Machine external interrupt!\n");break;
    case 7: printf("Machine software interrupt!\n");break;
    default: panic("Unhandled event ID = %d", e.event);
  }

  return c;
}

void init_irq(void) {
  Log("Initializing interrupt/exception handler...");
  cte_init(do_event);
}
