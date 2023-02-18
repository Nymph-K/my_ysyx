#define SDL_malloc  malloc
#define SDL_free    free
#define SDL_realloc realloc

#define SDL_STBIMAGE_IMPLEMENTATION
#include "SDL_stbimage.h"

SDL_Surface* IMG_Load_RW(SDL_RWops *src, int freesrc) {
  assert(src->type == RW_TYPE_MEM);
  assert(freesrc == 0);
  return NULL;
}

SDL_Surface* IMG_Load(const char *filename) {
  assert(filename);
  int fd = open(filename, 0, 0);
  if(!fd) return NULL;
  long fsize = lseek(fd, 0, SEEK_END);
  uint8_t *buf = malloc(fsize);
  if(!buf) return NULL;
  lseek(fd, 0, SEEK_SET);
  SDL_Surface *sf = NULL;
  if (read(fd, buf, fsize))
  {
    sf = STBIMG_LoadFromMemory(buf, fsize);
  }
  close(fd);
  free(buf);
  return sf;
}

int IMG_isPNG(SDL_RWops *src) {
  return 0;
}

SDL_Surface* IMG_LoadJPG_RW(SDL_RWops *src) {
  return IMG_Load_RW(src, 0);
}

char *IMG_GetError() {
  return "Navy does not support IMG_GetError()";
}
