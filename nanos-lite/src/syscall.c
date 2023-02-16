#include <common.h>
#include "syscall.h"
#include <fs.h>
#include <sys/time.h>

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

const char *myenumToString(int n) {
#define X(x) case (x): \
        { return #x; }
#define MAKE_ENUM_CASES \
    MY_ENUM_VALUES \
    default: { return "unknown enum string."; }

    switch (n) {
        MAKE_ENUM_CASES
    }
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime);

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
    case SYS_exit: 
      halt(a[1]); break;
    case SYS_yield: 
      yield(); c->GPRx = 0; 
      break;
    case SYS_open: 
      c->GPRx = fs_open((const char *)a[1], a[2], a[3]); 
      break;
    case SYS_read: 
      c->GPRx = fs_read(a[1], (char *)a[2], a[3]); 
      break;
    case SYS_write: 
      c->GPRx = fs_write(a[1], (const char *)a[2], a[3]); 
      break;
    case SYS_close: 
      c->GPRx = fs_close(a[1]); 
      break;
    case SYS_lseek: 
      c->GPRx = fs_lseek(a[1], a[2], a[3]); 
      break;
    case SYS_brk: 
      c->GPRx = 0; 
      break;
    case SYS_gettimeofday: 
      AM_TIMER_UPTIME_T uptime;
      __am_timer_uptime(&uptime);
      ((struct timeval *)(a[1]))->tv_sec = 0;
      ((struct timeval *)(a[1]))->tv_usec = uptime.us;
      c->GPRx = 0;
      break;
    default: panic("Unhandled syscall ID = %d", a[0]);
  }
  #if CONFIG_STRACE
    if (a[0] == SYS_open || a[0] == SYS_read || a[0] == SYS_write || a[0] == SYS_close || a[0] == SYS_lseek)
    {
      printf("System call [%16s] : file=%s args=(%l, %l) ret=%l\n", myenumToString(a[0]), a[0] == SYS_open ? (const char *)a[1] : fs_fname(a[1]), a[2], a[3], c->GPRx);
    }
    else
      printf("System call [%16s] : args=(%l, %l, %l) ret=%l\n", myenumToString(a[0]), a[1], a[2], a[3], c->GPRx);
  #endif
}
