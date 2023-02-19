#include <NDL.h>

int SDL_Init(uint32_t flags) {
  return NDL_Init(flags);
}

void SDL_Quit() {
  NDL_Quit();
}

char *SDL_GetError() {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return "Navy does not support SDL_GetError()";
}

int SDL_SetError(const char* fmt, ...) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return -1;
}

int SDL_ShowCursor(int toggle) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return 0;
}

void SDL_WM_SetCaption(const char *title, const char *icon) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}
