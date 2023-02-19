#include <NDL.h>
#include <SDL.h>

int SDL_OpenAudio(SDL_AudioSpec *desired, SDL_AudioSpec *obtained) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return 0;
}

void SDL_CloseAudio() {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}

void SDL_PauseAudio(int pause_on) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}

void SDL_MixAudio(uint8_t *dst, uint8_t *src, uint32_t len, int volume) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}

SDL_AudioSpec *SDL_LoadWAV(const char *file, SDL_AudioSpec *spec, uint8_t **audio_buf, uint32_t *audio_len) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
  return NULL;
}

void SDL_FreeWAV(uint8_t *audio_buf) {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}

void SDL_LockAudio() {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}

void SDL_UnlockAudio() {
  printf("%s [line:%d]: function: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}
