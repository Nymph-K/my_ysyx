#include <am.h>
#include <klib-macros.h>

int main(const char *args) {
  const char *fmt =
    "Hello, AbstractMachine!\n"
    "mainargs = '%'.\n";

  for (const char *p = fmt; *p; p++) {
    if(*p != '%')
      putch(*p);
    else{ 
      for (const char *p1 = args; *p1; p1++) 
        putch(*p1);
    }
  }
  return 0;
}
