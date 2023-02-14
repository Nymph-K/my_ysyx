#include <common.h>
#include "syscall.h"

#define MY_ENUM_VALUES \
                X(SYS_exit) \
                X(SYS_yield) \
                X(SYS_open) \
                X(SYS_read) \
                X(SYS_write) \
                X(SYS_kill) \
                X(SYS_getpid) \
                X(SYS_close) \
                X(SYS_lseek) \
                X(SYS_brk) \
                X(SYS_fstat) \
                X(SYS_time) \
                X(SYS_signal) \
                X(SYS_execve) \
                X(SYS_fork) \
                X(SYS_link) \
                X(SYS_unlink) \
                X(SYS_wait) \
                X(SYS_times) \
                X(SYS_gettimeofday)

enum {
  SYS_exit,
  SYS_yield,
  SYS_open,
  SYS_read,
  SYS_write,
  SYS_kill,
  SYS_getpid,
  SYS_close,
  SYS_lseek,
  SYS_brk,
  SYS_fstat,
  SYS_time,
  SYS_signal,
  SYS_execve,
  SYS_fork,
  SYS_link,
  SYS_unlink,
  SYS_wait,
  SYS_times,
  SYS_gettimeofday
};

const char *myenumToString(int n) {
#define X(x) case (x): { return #x; }
#define MAKE_ENUM_CASES \
    MY_ENUM_VALUES \
    default: { return "unknown enum string."; }

    switch (n) {
        MAKE_ENUM_CASES
    }
}

int sys_write(int fd, char *buf, size_t count)
{
  if(fd == 1 || fd == 2)
  {
    for (size_t i = 0; i < count; i++)
    {
      putch(*buf++);
    }
    return count;
  }
  else return -1;
}

void do_syscall(Context *c) {
  uintptr_t a[4];
  a[0] = c->GPR1;
  a[1] = c->GPR2;
  a[2] = c->GPR3;
  a[3] = c->GPR4;

  switch (a[0]) {
    case -1: 
        #if CONFIG_STRACE
            printf("System call [%16s] : args=(%l, %l, %l) ret=%l\n", "Event yield", a[1], a[2], a[3], c->GPRx);
        #endif
      return;
    case SYS_exit: halt(a[1]); break;
    case SYS_yield: yield(); c->GPRx = 0; break;
    case SYS_write: c->GPRx = sys_write(a[1], (char *)a[2], a[3]); break;
    case SYS_brk: c->GPRx = 0; break;
    default: panic("Unhandled syscall ID = %d", a[0]);
  }
  #if CONFIG_STRACE
    printf("System call [%16s] : args=(%l, %l, %l) ret=%l\n", myenumToString(a[0]), a[1], a[2], a[3], c->GPRx);
  #endif
}
