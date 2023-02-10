#include <am.h>
#include "npc.h"

void __am_clint_msip(AM_CLINT_MSIP_T *ptr)
{
  if(ptr->is_write)
    outl(CLINT_MSIP_ADDR, ptr->msip);
  else
    ptr->msip = inl(CLINT_MSIP_ADDR);
}

void __am_clint_mtimecmp(AM_CLINT_MTIMECMP_T *ptr)
{
  if(ptr->is_write)
    outo(CLINT_MTIMECMP_ADDR, ptr->mtimecmp);
  else
    ptr->mtimecmp = ino(CLINT_MTIMECMP_ADDR);
}

void __am_clint_mtime(AM_CLINT_MTIME_T *ptr)
{
  if(ptr->is_write)
    outo(CLINT_MTIME_ADDR, ptr->mtime);
  else
    ptr->mtime = ino(CLINT_MTIME_ADDR);
}

void __am_clint_init()
{
  AM_CLINT_MTIMECMP_T s;
  s.is_write = true;
  s.mtimecmp = 1;
  __am_clint_mtimecmp(&s);
  AM_CLINT_MTIME_T t;
  t.is_write = true;
  t.mtime = 0;
  __am_clint_mtime(&t);
}
