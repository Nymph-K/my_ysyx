#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static char sprint_buf[2048];

int printf(const char *fmt, ...) {
  va_list args; 
  int n;
  va_start(args, fmt);
  n = vsprintf(sprint_buf, fmt, args);
  va_end(args);
  for (size_t i = 0; i < 2048 && sprint_buf[i] != '\0'; i++)
  {
    putch(sprint_buf[i]);
  }
  
  return n;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  assert( out != NULL && fmt != NULL);

  int len = 0;
  bool is_arg = false;
  int d;
  char c;
  char *s;
  char d2s[32];
  bool align_left = false;
  bool sign_disp = false;
  bool pad_zero = false;
  int  width = 0;
  int  precision = 0;
  int  str_len = 0;
  int  spc_len = 0;
  int i;

  while (*fmt){
    if(is_arg)
    {
      switch (*fmt) {
        case 's':              /* string */
          s = va_arg(ap, char *);
          str_len = strlen(s);//string length
          spc_len = precision > 0 ? ((width > precision)?(width - precision):0) : (width > str_len ? width - str_len : 0);
          str_len = (precision == 0 ? str_len : precision);//print length
          if(align_left == false)// space' '
            for(i = 0; i < spc_len; i++)
            {
              *out++ = ' ';
              len++;
            }
          for(i = 0; i < str_len && *s != '\0'; i++)// string
          {
            *out++ = *s;
            len++;
            s++;
          }
          if(align_left == true)// space' '
            for(i = 0; i < spc_len; i++)
            {
              *out++ = ' ';
              len++;
            }
          is_arg = false;
          fmt++;
          break;
        case 'd':              /* int */
        case 'u':              /* unsigned int */
        case 'o':              /* unsigned int o*/
        case 'x':  case 'X':   /* unsigned int x*/
        case 'p':              /* pointer */
        case 'l':              /* long */
          switch (*fmt)
          {
            case 'd':              /* int */
              d = va_arg(ap, int);
              itoa(d, d2s, 10);
              break;

            case 'u':              /* unsigned int */
              d = va_arg(ap, unsigned int);
              itoa(d, d2s, 10);
              break;
            
            case 'o':              /* unsigned int o*/
              d = va_arg(ap, unsigned int);
              itoa(d, d2s, 8);
              break;

            case 'x':  case 'X':    /* unsigned int */
              d = va_arg(ap, unsigned int);
              itoa(d, d2s, 16);
              break;

            case 'p':               /* unsigned int */
              d = va_arg(ap, unsigned int);
              itoa(d, d2s, 16);
              // width = 16;
              // pad_zero = false;
              break;

            case 'l':              /* long */
              if (fmt[1] == 'u'){
                d = va_arg(ap, unsigned long);
                fmt++;
              }
              else
                d = va_arg(ap, long);
              ltoa(d, d2s, 10);
              break;

            default:
              break;
          }
          str_len = strlen(d2s);//string length
          spc_len = width > str_len ? width - str_len : 0;
          if (sign_disp && *d2s != '-')//sign +
          {
            spc_len -= 1;
          }
          if (*fmt == 'p')
          {
              *out++ = '0';len++;
              *out++ = 'x';len++;
          }
          char padding = (pad_zero == true) ? '0' : ' ';
          if(align_left == false) {// padding space' ' or zero'0'
            for(i = 0; i < spc_len; i++)
            {
              *out++ = padding;
              len++;
            }
          }
          if (sign_disp && *d2s != '-')//sign +
          {
            *out++ = '+';
            len++;
            width--;
          }
          for(i = 0; i < str_len; i++)
          {
            *out++ = d2s[i];
            len++;
          }
          if(align_left == true)// padding space' '
            for(i = 0; i < spc_len; i++)
            {
              *out++ = ' ';
              len++;
            }
          is_arg = false;
          fmt++;
          break;
        case 'c':              /* char */
          /* need a cast here since va_arg only
            takes fully promoted types */
          c = (char) va_arg(ap, int);
          *out++ = c;
          len++;
          is_arg = false;
          fmt++;
          break;
        case '%':              /* % */
          *out++ = '%';
          len++;
          is_arg = false;
          fmt++;
          break;
        case '-':              /* align left */
          align_left = true;
          fmt++;
          break;
        case '+':              /* +- sign */
          sign_disp = true;
          fmt++;
          break;
        case '0':              /* padding zero */
          pad_zero = true;
          fmt++;
          break;
        case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
          width = atoi(fmt);   /* width */
          while (*fmt >= '0' && *fmt <= '9') fmt++;
          break;
        case '*':
          width = va_arg(ap, int);   /* width */
          fmt++;
          break;
        case '.':              /* precision */
          fmt++;
          if (*fmt == '*')
          {
            precision = va_arg(ap, int);
            fmt++;
          }
          else
          {
            precision = atoi(fmt);
            while (*fmt >= '0' && *fmt <= '9') fmt++;
          }
          pad_zero = false;
          break;
      }
    }
    else
    {
      if(*fmt == '%') {
        is_arg = true;
        align_left = false;
        sign_disp = false;
        pad_zero = false;
        width = 0;
        precision = 0;
        str_len = 0;
        spc_len = 0;
      }
      else{
        *out++ = *fmt;
        len++;
      }
      fmt++;
    }
  }
 *out++ = '\0';
 return len;
}

int sprintf(char *out, const char *fmt, ...) {
	va_list args;
	int len;

	va_start(args, fmt);
	len = vsprintf(out,fmt,args);
	va_end(args);
	return len;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
