#include <NDL.h>
#include <SDL.h>

#define keyname(k) #k,
#define key_num (sizeof(keyname)/sizeof(keyname[0]))

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

int SDL_PushEvent(SDL_Event *ev) {
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  return 0;
}

int SDL_WaitEvent(SDL_Event *event) {
  char buf[32];
  char kd_ku;
  char key_name[20];
  while (!NDL_PollEvent(buf, sizeof(buf)));
  if(sscanf(buf, "k%c %s\n", &kd_ku, key_name) == 2)
  {
    event->type = kd_ku == 'u' ? SDL_KEYUP : SDL_KEYDOWN;
    for (size_t i = 0; i < key_num; i++)
    {
      if (strcmp(keyname[i], key_name) == 0)
      {
        printf("k%c %s\n", kd_ku, keyname[i]);
        event->key.type = event->type;
        event->key.keysym.sym = i;
        return i;
      }
    }
  }
  return 0;
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  return NULL;
}
