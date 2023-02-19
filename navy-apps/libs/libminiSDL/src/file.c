#include <sdl-file.h>

SDL_RWops* SDL_RWFromFile(const char *filename, const char *mode) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return NULL;
}

SDL_RWops* SDL_RWFromMem(void *mem, int size) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return NULL;
}
