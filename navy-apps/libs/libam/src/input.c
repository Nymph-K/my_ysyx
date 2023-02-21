#include <am.h>
#include <fcntl.h> 
#include <string.h>

#define keyname(k) #k,
#define key_num (sizeof(keyname)/sizeof(keyname[0]))

static const char *keyname[] = {
  "NONE",
  AM_KEYS(keyname)
};

uint8_t key_state[key_num] = {0};

static int fd_events = -1;

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  if(kbd == NULL) return ;
  if (fd_events == -1)
  {
    fd_events = open("/dev/events", O_RDONLY, 0);
    if(fd_events == 0) {return ;}
  }
  char buf[32];
  char kd_ku;
  char key_name[20];
  if(read(fd_events, buf, sizeof(buf)) != 0)
  {
    if(sscanf(buf, "k%c %s\n", &kd_ku, key_name) != 2) return ;
    for (size_t i = 0; i < key_num; i++)
    {
      if (strcmp(keyname[i], key_name) == 0)
      {
        kbd->keycode = i;
        kbd->keydown = kd_ku == 'd';
        return ;
      }
    }
  }
  kbd->keycode = AM_KEY_NONE;
  kbd->keydown = 0;
  return ;
}
