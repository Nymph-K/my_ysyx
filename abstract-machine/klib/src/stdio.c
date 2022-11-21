#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  assert( out != NULL && fmt != NULL);

  int len = 0;
  va_list ap;
  bool is_arg = false;
  int d;
  char c;
  char *s;
  char d2s[20];

  va_start(ap, fmt);
  while (*fmt){
    if(is_arg)
    {
      switch (*fmt) {
        case 's':              /* string */
          s = va_arg(ap, char *);
          while(*s != '\0')
          {
            *out++ = *s;
            len++;
            s++;
          }
          break;
        case 'd':              /* int */
          d = va_arg(ap, int);
          itoa(d, d2s, 10);
          for(int i = 0; d2s[i] != '\0'; i++)
          {
            *out++ = d2s[i];
            len++;
          }
          break;
        case 'c':              /* char */
          /* need a cast here since va_arg only
            takes fully promoted types */
          c = (char) va_arg(ap, int);
          *out++ = c;
          len++;
          break;
        case '%':              /* string */
          *out++ = '%';
          len++;
          break;
      }
      is_arg = false;
    }
    else
    {
      if(*fmt == '%') {
        is_arg = true;
      }
      else{
        *out++ = *fmt;
        len++;
      }
    }
    fmt++;
  }
 va_end(ap);
 *out++ = '\0';
 return len;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
