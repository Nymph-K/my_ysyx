#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  assert(s != NULL);

  size_t len;

  for (len = 0; s[len] != '\0'; len++)
    ;
  return len;
}

char *strcpy(char *dst, const char *src) {
  assert(dst != NULL && src != NULL);

  size_t i;

  for (i = 0; src[i] != '\0'; i++)
    dst[i] = src[i];
  dst[i] = '\0';
  return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
  assert(dst != NULL && src != NULL);

  size_t i;

  for (i = 0; i < n && src[i] != '\0'; i++)
    dst[i] = src[i];
  for ( ; i < n; i++)
    dst[i] = '\0';

  return dst;
}

char *strcat(char *dst, const char *src) {
  assert(dst != NULL && src != NULL);

  size_t i, len;

  len = strlen(dst);
  for (i = 0; src[i] != '\0'; i++)
      dst[len + i] = src[i];
  dst[len + i] = '\0';

  return dst;
}

char *strncat(char *dest, const char *src, size_t n)
{
  assert(dest != NULL && src != NULL);

  size_t dest_len = strlen(dest);
  size_t i;

  for (i = 0 ; i < n && src[i] != '\0' ; i++)
      dest[dest_len + i] = src[i];
  dest[dest_len + i] = '\0';

  return dest;
}

int strcmp(const char *s1, const char *s2) {
  assert(s1 != NULL && s2 != NULL);

  size_t i;
  int ret;

  for (i = 0 ; s1[i] == s2[i] && s1[i] != '\0'; i++)
    ;

  ret = (uint8_t)(s1[i]) - (uint8_t)(s2[i]);
	if (ret < 0)
	{
		return -1;
	}
	else if (ret > 0)
	{
		return 1;
	}
	return 0;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  if (n == 0) {
    return 0;
  }
  assert(s1 != NULL && s2 != NULL);

  size_t i;
  int ret;

  for (i = 0 ; s1[i] == s2[i] && s1[i] != '\0' && i < n; i++)
    ;

  if (i == n)
    return 0;
  else
    ret = (uint8_t)(s1[i]) - (uint8_t)(s2[i]);
	if (ret < 0)
	{
		return -1;
	}
	else if (ret > 0)
	{
		return 1;
	}
	return 0;
}

void *memset(void *s, int c, size_t n) {
  assert(s != NULL);

  size_t i;
  uint8_t *dst = (uint8_t *)s;

  for (i = 0 ; i < n; i++)
    dst[i] = c;

  return s;
}

// void *memmove(void *dst, const void *src, size_t n) {
//   assert(dst != NULL && src != NULL) ;

//   size_t i;
//   uint8_t *d = dst;
//   const uint8_t *s = src;
  
//   if(d == s) return dst;
//   if(d < s){
//     for (i = 0 ; i < n; i++)
//       d[i] = s[i];
//   }
//   else{
//     for (i = n-1 ; i >= 0; i--)
//       d[i] = s[i];
//   }

//   return dst;
// }
void* memmove(void* dst,const void* src,size_t count)
{
    assert(NULL !=src && NULL !=dst);
    char* tmpdst = (char*)dst;
    char* tmpsrc = (char*)src;

    if (tmpdst <= tmpsrc || tmpdst >= tmpsrc + count)
    {
        while(count--)
        {
            *tmpdst++ = *tmpsrc++; 
        }
    }
    else
    {
        tmpdst = tmpdst + count - 1;
        tmpsrc = tmpsrc + count - 1;
        while(count--)
        {
            *tmpdst-- = *tmpsrc--;
        }
    }
    return dst; 
}

void *memcpy(void *out, const void *in, size_t n) {
  assert(out != NULL && in != NULL);

  size_t i;
  uint8_t *d = out;
  const uint8_t *s = in;

  for (i = 0 ; i < n; i++)
      d[i] = s[i];

  return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  if (n == 0) {
    return 0;
  }
  assert(s1 != NULL && s2 != NULL);

  size_t i;
  int ret;
  const uint8_t *m1 = s1;
  const uint8_t *m2 = s2;

  for (i = 0 ; m1[i] == m2[i] && i < n; i++)
    ;
  if(i == n)
    return 0;
  else
    ret = m1[i] - m2[i];
	if (ret < 0)
	{
		return -1;
	}
	else if (ret > 0)
	{
		return 1;
	}
	return 0;
}

#endif
