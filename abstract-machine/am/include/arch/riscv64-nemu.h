#ifndef ARCH_H__
#define ARCH_H__

struct Context {
  uintptr_t gpr[32];
  uintptr_t mcause;
  uintptr_t mstatus;
  uintptr_t mepc;
  void *pdir;
};

#define GPR1 gpr[17] // a7
#define GPR2 gpr[10]
#define GPR3 gpr[11]
#define GPR4 gpr[12]
#define GPRx gpr[10]
#endif
