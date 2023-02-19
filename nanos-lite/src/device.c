#include <common.h>

#if defined(MULTIPROGRAM) && !defined(TIME_SHARING)
# define MULTIPROGRAM_YIELD() yield()
#else
# define MULTIPROGRAM_YIELD()
#endif

#define NAME(key) \
  [AM_KEY_##key] = #key,

static const char *keyname[256] __attribute__((used)) = {
  [AM_KEY_NONE] = "NONE",
  AM_KEYS(NAME)
};

size_t serial_write(const void *buf, size_t offset, size_t len) {
  for (size_t i = 0; i < len; i++)
  {
    putch(*(char *)buf++);
  }
  return len;
}

size_t events_read(void *buf, size_t offset, size_t len) {
  AM_INPUT_KEYBRD_T kbd;
  ioe_read(AM_INPUT_KEYBRD, &kbd);
  if(kbd.keycode != AM_KEY_NONE)
  {
    if (kbd.keydown)
    {
      return snprintf(buf, len, "kd %s\n", keyname[kbd.keycode]);
    }
    else
    {
      return snprintf(buf, len, "ku %s\n", keyname[kbd.keycode]);
    }
  }
  return 0;
}

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  AM_GPU_CONFIG_T cfg;
  ioe_read(AM_GPU_CONFIG, &cfg);
  return snprintf(buf, len, "WIDTH:%d\nHEIGHT:%d\n", cfg.width, cfg.height);
}

size_t get_fbsize(void)
{
  AM_GPU_CONFIG_T cfg;
  ioe_read(AM_GPU_CONFIG, &cfg);
  return cfg.vmemsz;
}

size_t fb_write(const void *buf, size_t offset, size_t len) {
  AM_GPU_CONFIG_T cfg;
  ioe_read(AM_GPU_CONFIG, &cfg);
  AM_GPU_FBDRAW_T ctl;

  ctl.x = (offset / 4) % cfg.width;
  ctl.y = (offset / 4) / cfg.width;
  ctl.pixels = (void *)buf;
  ctl.w = len / 4;
  if (ctl.w > cfg.width && offset == 0)
  {
    ctl.h = ctl.w / cfg.width;
    ctl.w = cfg.width;
    ctl.sync = 1;
  }
  else
  {
    ctl.h = 1;
    ctl.sync = 1;
  }
  ioe_write(AM_GPU_FBDRAW, &ctl);
  return len;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
  Log("Finish initialize");
}
