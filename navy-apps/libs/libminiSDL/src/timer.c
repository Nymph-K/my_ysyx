#include <NDL.h>
#include <sdl-timer.h>
#include <stdio.h>

SDL_TimerID SDL_AddTimer(uint32_t interval, SDL_NewTimerCallback callback, void *param) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return NULL;
}

int SDL_RemoveTimer(SDL_TimerID id) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return 1;
}

uint32_t SDL_GetTicks() {
  return NDL_GetTicks();
}

void SDL_Delay(uint32_t ms) {
  uint32_t statr_tick = NDL_GetTicks();
  uint32_t current_tick = NDL_GetTicks();
  while (current_tick - statr_tick < ms)
  {
    current_tick = NDL_GetTicks();
  }
}
