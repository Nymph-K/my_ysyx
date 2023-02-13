#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  //printf("mcause = 0x%lX,   mstatus = 0x%lX,   mepc = 0x%lX\n", c->mcause, c->mstatus, c->mepc);
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
      //case 0x01: ev.event = EVENT_SYSCALL; c->mepc += 4; break;//system call
      case 0x0B: ev.event = EVENT_SYSCALL; c->mepc += 4; break; //yield
      case 0x8000000000000007: ev.event = EVENT_IRQ_TIMER; c->mepc += 4; break;//Machine timer interrupt
      case 0x800000000000000B: ev.event = EVENT_IRQ_IODEV; c->mepc += 4; break;//Machine external interrupt
      case 0x8000000000000003: ev.event = EVENT_IRQ_SOFT; c->mepc += 4; break; //Machine software interrupt
      default: ev.event = EVENT_ERROR; break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
  }
  asm volatile("csrs mstatus, 0x8");//MIE=1
  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));
  uint64_t mstatus_val = 0xa00001800;//SXL=2, UXL=2, MPP=3
  asm volatile("csrw mstatus, %0" : : "r"(mstatus_val));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  return NULL;
}

void yield() {
  asm volatile("li a7, -1; ecall");
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
  if (enable)
  {
    uint64_t mie_en = 0x888;//MEIE=1, MTIE=1, MSIE=1
    asm volatile("csrw mie, %0" : : "r"(mie_en));
    asm volatile("csrs mstatus, 0x8");//MIE=1
  }
  else
  {
    uint64_t mie_en = 0x888;//MEIE=0, MTIE=0, MSIE=0
    asm volatile("csrc mie, %0" : : "r"(mie_en));
    asm volatile("csrc mstatus, 0x8");//MIE=0
  }
}
